using System;
using System.Web.UI;

namespace DeltaTradeHub
{
    public partial class Logout : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // 清除所有 Session
            Session.Clear();
            Session.Abandon();

            // 清除身份验证 Cookie（如果有）
            if (Request.Cookies["TarkovUser"] != null)
            {
                var cookie = new System.Web.HttpCookie("TarkovUser");
                cookie.Expires = DateTime.Now.AddDays(-1);
                Response.Cookies.Add(cookie);
            }

            // 重定向到登录页
            Response.Redirect("Auth.aspx");
        }
    }
}