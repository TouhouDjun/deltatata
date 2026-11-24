using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.EntityClient;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Web.Hosting;

namespace deltatata.App_Start
{
    /// <summary>
    /// 站点启动时的数据库自动初始化：
    /// 1) 连接 master，连接串中指定的数据库不存在时自动创建；
    /// 2) 目标库还是空库（以 Users 表是否存在判断）时，执行 App_Data/InitDatabase.sql 建表并写入演示数据。
    /// 初始化失败不会阻断站点启动，失败原因写入 App_Data/DatabaseInit.log。
    /// 在 Web.config 的 appSettings 里把 DatabaseAutoInit 设为 false 可以关闭自动初始化。
    /// </summary>
    public static class DatabaseInitializer
    {
        private const string ConnectionStringName = "DeltaTradeHubDBEntities";
        private const string InitScriptAppRelativePath = "~/App_Data/InitDatabase.sql";
        private const string LogFileName = "DatabaseInit.log";

        private static readonly object SyncRoot = new object();
        private static readonly Regex GoLineRegex = new Regex(@"^\s*GO\s*(\d+)?\s*$", RegexOptions.IgnoreCase | RegexOptions.Compiled);
        private static bool _initialized;

        /// <summary>在 Global.asax 的 Application_Start 中调用。幂等，多次调用只会执行一次。</summary>
        public static void Initialize()
        {
            if (_initialized)
                return;

            lock (SyncRoot)
            {
                if (_initialized)
                    return;

                try
                {
                    string autoInit = ConfigurationManager.AppSettings["DatabaseAutoInit"];
                    if (!string.IsNullOrEmpty(autoInit) && autoInit.Equals("false", StringComparison.OrdinalIgnoreCase))
                    {
                        _initialized = true;
                        return;
                    }

                    ConnectionStringSettings settings = ConfigurationManager.ConnectionStrings[ConnectionStringName];
                    if (settings == null || string.IsNullOrEmpty(settings.ConnectionString))
                        throw new InvalidOperationException("Web.config 中缺少名为 " + ConnectionStringName + " 的连接字符串。");

                    string providerConnectionString = GetProviderConnectionString(settings.ConnectionString);
                    string scriptPath = HostingEnvironment.MapPath(InitScriptAppRelativePath);
                    if (string.IsNullOrEmpty(scriptPath) || !File.Exists(scriptPath))
                        throw new FileNotFoundException("找不到数据库初始化脚本：" + InitScriptAppRelativePath, scriptPath);

                    InitializeDatabase(providerConnectionString, scriptPath);
                    _initialized = true;
                }
                catch (Exception ex)
                {
                    WriteLog("数据库自动初始化失败：", ex);
                }
            }
        }

        /// <summary>
        /// 建库并执行初始化脚本。供启动流程调用，也方便单独测试。
        /// 已存在的库、已初始化过的库不会重复处理，可以安全地多次调用。
        /// </summary>
        public static void InitializeDatabase(string providerConnectionString, string scriptPath)
        {
            if (string.IsNullOrEmpty(providerConnectionString))
                throw new ArgumentNullException("providerConnectionString");
            if (string.IsNullOrEmpty(scriptPath) || !File.Exists(scriptPath))
                throw new FileNotFoundException("找不到数据库初始化脚本：" + scriptPath, scriptPath);

            SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder(providerConnectionString);
            if (string.IsNullOrEmpty(builder.InitialCatalog))
                throw new InvalidOperationException("连接字符串中缺少 initial catalog（数据库名）。");

            EnsureDatabaseExists(builder);

            using (SqlConnection connection = new SqlConnection(builder.ConnectionString))
            {
                connection.Open();

                if (IsDatabaseInitialized(connection))
                {
                    WriteLog("数据库已存在并初始化过，跳过初始化脚本。数据库：" + builder.InitialCatalog);
                    return;
                }

                string script = File.ReadAllText(scriptPath, Encoding.UTF8);
                ExecuteScript(connection, script);
                WriteLog("数据库初始化完成。数据库：" + builder.InitialCatalog);
            }
        }

        /// <summary>连接 master，目标数据库不存在时创建。</summary>
        private static void EnsureDatabaseExists(SqlConnectionStringBuilder builder)
        {
            SqlConnectionStringBuilder masterBuilder = new SqlConnectionStringBuilder(builder.ConnectionString);
            masterBuilder.InitialCatalog = "master";

            using (SqlConnection connection = new SqlConnection(masterBuilder.ConnectionString))
            {
                connection.Open();

                using (SqlCommand command = connection.CreateCommand())
                {
                    command.CommandText = "SELECT COUNT(*) FROM sys.databases WHERE name = @name";
                    command.Parameters.AddWithValue("@name", builder.InitialCatalog);
                    int exists = Convert.ToInt32(command.ExecuteScalar());
                    if (exists > 0)
                        return;

                    command.Parameters.Clear();
                    command.CommandText = "CREATE DATABASE " + QuoteIdentifier(builder.InitialCatalog);
                    command.ExecuteNonQuery();
                }
            }
        }

        /// <summary>库里有 Users 表即视为已初始化（Users 是脚本里第一张业务表）。</summary>
        private static bool IsDatabaseInitialized(SqlConnection connection)
        {
            using (SqlCommand command = connection.CreateCommand())
            {
                command.CommandText = "SELECT CASE WHEN OBJECT_ID(N'Users', N'U') IS NULL THEN 0 ELSE 1 END";
                command.CommandTimeout = 60;
                return Convert.ToInt32(command.ExecuteScalar()) == 1;
            }
        }

        /// <summary>按行首单独的 GO 拆批执行，GO 是 SSMS 的批处理分隔符而不是 T-SQL 语法。</summary>
        private static void ExecuteScript(SqlConnection connection, string script)
        {
            foreach (string batch in SplitBatches(script))
            {
                using (SqlCommand command = connection.CreateCommand())
                {
                    command.CommandText = batch;
                    command.CommandTimeout = 300;
                    command.ExecuteNonQuery();
                }
            }
        }

        /// <summary>把脚本拆成批次。拆分规则：独占一行的 GO 或 GO 数字。</summary>
        internal static List<string> SplitBatches(string script)
        {
            List<string> batches = new List<string>();
            StringBuilder current = new StringBuilder();

            string normalized = script.Replace("\r\n", "\n").Replace('\r', '\n');
            string[] lines = normalized.Split('\n');
            foreach (string line in lines)
            {
                if (GoLineRegex.IsMatch(line))
                {
                    AddBatch(batches, current);
                }
                else
                {
                    current.Append(line);
                    current.Append('\n');
                }
            }

            AddBatch(batches, current);
            return batches;
        }

        private static void AddBatch(List<string> batches, StringBuilder current)
        {
            string batch = current.ToString().Trim();
            current.Length = 0;
            if (batch.Length > 0)
                batches.Add(batch);
        }

        /// <summary>从 EntityClient 连接串中取出底层 SqlClient 连接串。</summary>
        private static string GetProviderConnectionString(string entityConnectionString)
        {
            EntityConnectionStringBuilder builder = new EntityConnectionStringBuilder(entityConnectionString);
            if (string.IsNullOrEmpty(builder.ProviderConnectionString))
                throw new InvalidOperationException("连接字符串中没有 provider connection string。");
            return builder.ProviderConnectionString;
        }

        /// <summary>数据库名方括号转义，避免拼接 SQL 时被特殊字符破坏。</summary>
        private static string QuoteIdentifier(string name)
        {
            return "[" + name.Replace("]", "]]") + "]";
        }

        private static void WriteLog(string message)
        {
            WriteLog(message, null);
        }

        private static void WriteLog(string message, Exception ex)
        {
            try
            {
                string appDataPath = HostingEnvironment.MapPath("~/App_Data/");
                if (string.IsNullOrEmpty(appDataPath))
                    return;

                Directory.CreateDirectory(appDataPath);
                StringBuilder log = new StringBuilder();
                log.Append('[').Append(DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss")).Append("] ").Append(message);
                if (ex != null)
                {
                    log.AppendLine();
                    log.Append(ex);
                }
                log.AppendLine().AppendLine();

                File.AppendAllText(Path.Combine(appDataPath, LogFileName), log.ToString(), Encoding.UTF8);
            }
            catch
            {
                // 记日志失败时保持沉默，不能因为日志问题影响站点启动。
            }
        }
    }
}
