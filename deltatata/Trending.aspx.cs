using System;
using System.Web.UI;

namespace DeltaTradeHub
{
    public partial class Trending : Page
    {
        private int CurrentUserId => Session["UserId"] != null ? (int)Session["UserId"] : 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (CurrentUserId == 0)
            {
                Response.Redirect("Auth.aspx");
                return;
            }
            // 无需其他代码，所有数据由前端 JavaScript 模拟
        }
    }
}