using System;
using System.Web.UI;
using deltatata.Models;

namespace DeltaTradeHub
{
    public partial class AdminMaster : MasterPage
    {
        private int CurrentUserId => Session["UserId"] != null ? (int)Session["UserId"] : 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            // 检查是否已登录
            if (CurrentUserId == 0)
            {
                Response.Redirect("Auth.aspx");
                return;
            }

            // 检查是否为管理员（根据用户名 admin1 或 Session["IsAdmin"]）
            if (!IsAdmin())
            {
                // 已登录但不是管理员，跳转到普通用户首页
                Response.Redirect("Market.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadAdminInfo();
            }
        }

        private bool IsAdmin()
        {
            // 首先尝试从 Session 获取 IsAdmin 标志
            if (Session["IsAdmin"] != null && (bool)Session["IsAdmin"])
                return true;

            // 备用：从数据库验证用户名
            using (var db = new DeltaTradeHubDBEntities())
            {
                var user = db.Users.Find(CurrentUserId);
                return user != null && user.Username == "admin1";
            }
        }

        private void LoadAdminInfo()
        {
            using (var db = new DeltaTradeHubDBEntities())
            {
                var user = db.Users.Find(CurrentUserId);
                if (user != null)
                {
                    litUsername.Text = user.Username;
                    if (!string.IsNullOrEmpty(user.AvatarUrl))
                        imgAvatar.ImageUrl = user.AvatarUrl;
                }
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Auth.aspx");
        }
    }
}