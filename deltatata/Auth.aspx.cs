using deltatata.Models;
using System;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.UI;

namespace DeltaTradeHub
{
    public partial class Auth : Page
    {
        private DeltaTradeHubDBEntities db = new DeltaTradeHubDBEntities();

        protected void Page_Load(object sender, EventArgs e)
        {
            // 已登录用户跳转（管理员→Admin.aspx，普通用户→Market.aspx）
            if (Session["UserId"] != null)
            {
                bool isAdmin = Session["IsAdmin"] != null && (bool)Session["IsAdmin"];
                Response.Redirect(isAdmin ? "AdminDashboard.aspx" : "Market.aspx");
            }

            if (!IsPostBack)
            {
                // 自动初始化管理员账号（用户名 admin1，密码 123456）
                InitAdminAccount();

                // 读取记住密码的Cookie
                HttpCookie cookie = Request.Cookies["TarkovUser"];
                if (cookie != null && !string.IsNullOrEmpty(cookie["Username"]))
                {
                    txtLoginUsername.Text = cookie["Username"];
                    chkRemember.Checked = true;
                }

                // 注册成功提示
                if (Request.QueryString["regSuccess"] == "1")
                {
                    string username = Uri.UnescapeDataString(Request.QueryString["user"] ?? "");
                    ShowRegMessage($"恭喜 {username}，注册成功！请登录", true);
                }
            }
        }

        /// <summary>
        /// 初始化管理员账号（用户名 admin1，密码 123456）
        /// </summary>
        private void InitAdminAccount()
        {
            try
            {
                string adminUsername = "admin1";
                string adminPassword = "123456";
                string adminEmail = "admin@tarkovhub.com";

                var existingAdmin = db.Users.FirstOrDefault(u => u.Username == adminUsername);
                if (existingAdmin == null)
                {
                    string hashedPwd = ComputeSha256Hash(adminPassword);
                    var adminUser = new Users
                    {
                        Username = adminUsername,
                        PasswordHash = hashedPwd,
                        Email = adminEmail,
                        Balance = 999999m,
                        AvatarUrl = "https://randomuser.me/api/portraits/lego/1.jpg",
                        RegisterDate = DateTime.Now,
                        LastLoginDate = DateTime.Now,
                        IsActive = true
                    };
                    db.Users.Add(adminUser);
                    db.SaveChanges();
                }
                else
                {
                    // 确保密码和激活状态正确
                    existingAdmin.PasswordHash = ComputeSha256Hash(adminPassword);
                    existingAdmin.IsActive = true;
                    db.SaveChanges();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"初始化管理员异常: {ex.Message}");
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            try
            {
                string username = txtLoginUsername.Text.Trim();
                string password = txtLoginPassword.Text.Trim();

                if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
                {
                    ShowLoginError("用户名和密码不能为空");
                    return;
                }

                string hashedPwd = ComputeSha256Hash(password);
                var user = db.Users.FirstOrDefault(u =>
                    u.Username == username &&
                    u.PasswordHash == hashedPwd &&
                    u.IsActive == true);

                if (user != null)
                {
                    // 判断是否为管理员（用户名 admin1）
                    bool isAdmin = username.Equals("admin1", StringComparison.OrdinalIgnoreCase);

                    Session["UserId"] = user.UserId;
                    Session["Username"] = user.Username;
                    Session["Balance"] = user.Balance;
                    Session["AvatarUrl"] = user.AvatarUrl;
                    Session["IsAdmin"] = isAdmin;

                    user.LastLoginDate = DateTime.Now;
                    db.SaveChanges();

                    if (chkRemember.Checked)
                    {
                        HttpCookie cookie = new HttpCookie("TarkovUser");
                        cookie["Username"] = username;
                        cookie.Expires = DateTime.Now.AddDays(7);
                        Response.Cookies.Add(cookie);
                    }
                    else
                    {
                        if (Request.Cookies["TarkovUser"] != null)
                            Response.Cookies["TarkovUser"].Expires = DateTime.Now.AddDays(-1);
                    }

                    // 跳转对应页面（管理员跳转到 AdminDashboard.aspx，普通用户跳转到 Market.aspx）
                    Response.Redirect(isAdmin ? "AdminDashboard.aspx" : "Market.aspx");
                }
                else
                {
                    ShowLoginError("用户名/密码错误，或账号已被禁用");
                }
            }
            catch (Exception ex)
            {
                ShowLoginError($"登录异常: {ex.Message}");
                System.Diagnostics.Debug.WriteLine(ex.ToString());
            }
        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            try
            {
                string username = txtRegUsername.Text.Trim();
                string email = txtRegEmail.Text.Trim();
                string password = txtRegPassword.Text.Trim();
                string confirmPwd = txtRegConfirmPassword.Text.Trim();

                if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password))
                {
                    ShowRegMessage("请完整填写所有必填字段", false);
                    return;
                }
                if (password != confirmPwd)
                {
                    ShowRegMessage("两次输入的密码不一致", false);
                    return;
                }
                if (username.Length < 3 || username.Length > 20)
                {
                    ShowRegMessage("用户名长度需在3-20个字符之间", false);
                    return;
                }
                if (username.Equals("admin1", StringComparison.OrdinalIgnoreCase))
                {
                    ShowRegMessage("该用户名不允许注册", false);
                    return;
                }

                if (db.Users.Any(u => u.Username == username))
                {
                    ShowRegMessage("用户名已被占用，请更换", false);
                    return;
                }
                if (db.Users.Any(u => u.Email == email))
                {
                    ShowRegMessage("该邮箱已注册过账号", false);
                    return;
                }

                string hashedPwd = ComputeSha256Hash(password);
                var newUser = new Users
                {
                    Username = username,
                    PasswordHash = hashedPwd,
                    Email = email,
                    Balance = 5000m,
                    AvatarUrl = "https://randomuser.me/api/portraits/lego/1.jpg",
                    RegisterDate = DateTime.Now,
                    LastLoginDate = DateTime.Now,
                    IsActive = true
                };

                db.Users.Add(newUser);
                db.SaveChanges();

                try
                {
                    var medItem = db.Items.FirstOrDefault(i => i.ItemName.Contains("医疗包"));
                    if (medItem != null)
                    {
                        var inventoryItem = new Inventory
                        {
                            UserId = newUser.UserId,
                            ItemId = medItem.ItemId,
                            Quantity = 2,
                            AcquireDate = DateTime.Now
                        };
                        db.Inventory.Add(inventoryItem);
                        db.SaveChanges();
                    }
                }
                catch { }

                Response.Redirect($"Auth.aspx?regSuccess=1&user={Uri.EscapeDataString(username)}");
            }
            catch (Exception ex)
            {
                ShowRegMessage($"注册失败: {ex.Message}", false);
                System.Diagnostics.Debug.WriteLine(ex.ToString());
            }
        }

        #region 辅助方法
        private void ShowLoginError(string msg)
        {
            lblLoginError.Text = msg;
            phLoginError.Visible = true;
        }

        private void ShowRegMessage(string msg, bool isSuccess)
        {
            lblRegMessage.Text = msg;
            phRegMessage.Visible = true;
            regMsgPanel.Attributes["class"] = isSuccess ? "alert-success-custom" : "alert-custom";
        }

        private string ComputeSha256Hash(string rawData)
        {
            using (SHA256 sha256Hash = SHA256.Create())
            {
                byte[] bytes = sha256Hash.ComputeHash(Encoding.UTF8.GetBytes(rawData));
                StringBuilder builder = new StringBuilder();
                for (int i = 0; i < bytes.Length; i++)
                {
                    builder.Append(bytes[i].ToString("x2"));
                }
                return builder.ToString();
            }
        }
        #endregion
    }
}