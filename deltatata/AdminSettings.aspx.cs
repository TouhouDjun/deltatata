using System;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web.UI;
using deltatata.Models;

namespace DeltaTradeHub
{
    public partial class AdminSettings : Page
    {
        private DeltaTradeHubDBEntities db = new DeltaTradeHubDBEntities();
        private int CurrentUserId => Session["UserId"] != null ? (int)Session["UserId"] : 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            // 权限验证
            if (Session["UserId"] == null || !(Session["IsAdmin"] is true))
            {
                Response.Redirect("Auth.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadSettings();
            }
        }

        private void LoadSettings()
        {
            txtPlatformName.Text = GetSetting("PlatformName", "塔科夫交易行");
            txtCustomerService.Text = GetSetting("CustomerService", "service@tarkovhub.com");
            txtFeeRate.Text = GetSetting("TransactionFeeRate", "0.05");
            txtAdminNotice.Text = GetSetting("AdminNotice", "欢迎来到管理后台");
        }

        private string GetSetting(string key, string defaultValue)
        {
            var setting = db.SystemSettings.FirstOrDefault(s => s.SettingKey == key);
            return setting != null ? setting.SettingValue : defaultValue;
        }

        private void SetSetting(string key, string value)
        {
            var setting = db.SystemSettings.FirstOrDefault(s => s.SettingKey == key);
            if (setting != null)
                setting.SettingValue = value;
            else
            {
                db.SystemSettings.Add(new SystemSettings
                {
                    SettingKey = key,
                    SettingValue = value
                });
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            // 保存基础设置
            SetSetting("PlatformName", txtPlatformName.Text.Trim());
            SetSetting("CustomerService", txtCustomerService.Text.Trim());
            SetSetting("TransactionFeeRate", txtFeeRate.Text.Trim());
            SetSetting("AdminNotice", txtAdminNotice.Text.Trim());

            // 修改密码
            string oldPwd = txtOldPassword.Text.Trim();
            string newPwd = txtNewPassword.Text.Trim();
            string confirmPwd = txtConfirmPassword.Text.Trim();

            if (!string.IsNullOrEmpty(oldPwd) || !string.IsNullOrEmpty(newPwd))
            {
                if (string.IsNullOrEmpty(oldPwd) || string.IsNullOrEmpty(newPwd))
                {
                    ShowMessage("旧密码和新密码都不能为空", true);
                    return;
                }
                if (newPwd != confirmPwd)
                {
                    ShowMessage("两次输入的新密码不一致", true);
                    return;
                }

                var user = db.Users.Find(CurrentUserId);
                if (user == null || user.PasswordHash != ComputeSha256Hash(oldPwd))
                {
                    ShowMessage("旧密码错误", true);
                    return;
                }

                user.PasswordHash = ComputeSha256Hash(newPwd);
                ShowMessage("密码修改成功！");
            }

            db.SaveChanges();
            ShowMessage("设置保存成功！");
            LoadSettings(); // 刷新显示
        }

        private string ComputeSha256Hash(string rawData)
        {
            using (SHA256 sha256Hash = SHA256.Create())
            {
                byte[] bytes = sha256Hash.ComputeHash(Encoding.UTF8.GetBytes(rawData));
                StringBuilder builder = new StringBuilder();
                for (int i = 0; i < bytes.Length; i++)
                    builder.Append(bytes[i].ToString("x2"));
                return builder.ToString();
            }
        }

        private void ShowMessage(string msg, bool isError = false)
        {
            string script = $"alert('{(isError ? "❌ " : "✅ ")}{msg.Replace("'", "\\'")}');";
            ClientScript.RegisterStartupScript(GetType(), "toast", script, true);
        }
    }
}