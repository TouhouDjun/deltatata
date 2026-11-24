using System;
using System.Linq;
using System.Web.UI;
using deltatata.Models;

namespace DeltaTradeHub
{
    public partial class AdminDashboard : Page
    {
        private DeltaTradeHubDBEntities db = new DeltaTradeHubDBEntities();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null || !(Session["IsAdmin"] is true))
            {
                Response.Redirect("Auth.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadStatistics();
            }
        }

        private void LoadStatistics()
        {
            // 总用户数（激活用户）
            int totalUsers = db.Users.Count(u => u.IsActive == true);
            litTotalUsers.Text = totalUsers.ToString("N0");

            // 今日日期范围
            var today = DateTime.Now.Date;
            var tomorrow = today.AddDays(1);

            // 今日订单数（交易记录）
            int todayOrders = db.Transactions.Count(t => t.TransactionDate >= today && t.TransactionDate < tomorrow && t.Status == "Completed");
            litTodayOrders.Text = todayOrders.ToString("N0");

            // 今日交易额（已完成订单的总金额）
            decimal todayTurnover = db.Transactions
                .Where(t => t.TransactionDate >= today && t.TransactionDate < tomorrow && t.Status == "Completed")
                .Sum(t => (decimal?)t.TotalAmount) ?? 0;
            litTodayTurnover.Text = todayTurnover.ToString("N2");

            // 待审核充值单
            int pendingRecharge = db.RechargeOrders.Count(r => r.Status == "Pending");
            litPendingRecharge.Text = pendingRecharge.ToString("N0");
        }
    }
}