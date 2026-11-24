using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using deltatata.Models;

namespace DeltaTradeHub
{
    public partial class AdminRecharge : Page
    {
        private int pageSize = 10;

        protected void Page_Load(object sender, EventArgs e)
        {
            // 权限验证
            if (Session["UserId"] == null || !(Session["IsAdmin"] is true))
            {
                Response.Redirect("Auth.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!IsPostBack)
            {
                BindDropDownList();
                LoadRechargeOrders();
            }
        }

        private void BindDropDownList()
        {
            ddlStatus.Items.Clear();
            ddlStatus.Items.Add(new ListItem("全部", "All"));
            ddlStatus.Items.Add(new ListItem("待审核", "Pending"));
            ddlStatus.Items.Add(new ListItem("已通过", "Approved"));
            ddlStatus.Items.Add(new ListItem("已拒绝", "Rejected"));

            // 从 URL 读取 status 参数，默认为 Pending
            string statusParam = Request.QueryString["status"];
            if (!string.IsNullOrEmpty(statusParam))
            {
                ddlStatus.SelectedValue = statusParam;
            }
            else
            {
                ddlStatus.SelectedValue = "Pending";
            }
        }

        private void LoadRechargeOrders()
        {
            int currentPage = 1;
            int.TryParse(Request.QueryString["page"], out currentPage);
            if (currentPage < 1) currentPage = 1;

            string currentStatus = ddlStatus.SelectedValue;

            using (var db = new DeltaTradeHubDBEntities())
            {
                // 查询数据库中的充值订单，按时间倒序
                var allOrders = db.RechargeOrders
                    .AsNoTracking()
                    .OrderByDescending(r => r.CreateTime)
                    .ToList();

                // 筛选（注意：状态字符串必须严格匹配数据库中的值）
                var filteredOrders = allOrders;
                if (currentStatus != "All")
                {
                    filteredOrders = allOrders.Where(r => r.Status == currentStatus).ToList();
                }

                int totalCount = filteredOrders.Count;
                int totalPages = (int)Math.Ceiling((double)totalCount / pageSize);
                if (currentPage > totalPages && totalPages > 0) currentPage = totalPages;

                // 分页并关联用户名
                var pagedOrders = filteredOrders
                    .Skip((currentPage - 1) * pageSize)
                    .Take(pageSize)
                    .Select(r => new
                    {
                        r.Id,
                        r.UserId,
                        r.Amount,
                        r.Status,
                        r.CreateTime,
                        Username = db.Users.Where(u => u.UserId == r.UserId).Select(u => u.Username).FirstOrDefault() ?? "未知用户"
                    })
                    .ToList();

                rptRecharge.DataSource = pagedOrders;
                rptRecharge.DataBind();

                if (pagedOrders.Any())
                {
                    BuildPagination(totalPages, currentPage, currentStatus);
                    paginationDiv.Visible = true;
                }
                else
                {
                    paginationDiv.Visible = false;
                }
            }
        }

        private void BuildPagination(int totalPages, int currentPage, string currentStatus)
        {
            if (totalPages <= 1) { paginationDiv.Visible = false; return; }
            paginationDiv.Visible = true;

            var pageLinks = new List<PageLink>();
            for (int i = 1; i <= totalPages; i++)
            {
                string url = $"AdminRecharge.aspx?page={i}&status={currentStatus}";
                pageLinks.Add(new PageLink
                {
                    Text = i.ToString(),
                    Url = url,
                    CssClass = i == currentPage ? "active" : ""
                });
            }
            rptPagination.DataSource = pageLinks;
            rptPagination.DataBind();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            // 点击筛选按钮，重置到第一页并带上新的状态参数
            string url = $"AdminRecharge.aspx?page=1&status={ddlStatus.SelectedValue}";
            Response.Redirect(url, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        protected void rptRecharge_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int orderId = Convert.ToInt32(e.CommandArgument);

            using (var db = new DeltaTradeHubDBEntities())
            {
                var order = db.RechargeOrders.Find(orderId);
                if (order == null || order.Status != "Pending")
                {
                    ShowMessage("订单不存在或已处理", true);
                    return;
                }

                if (e.CommandName == "Approve")
                {
                    var user = db.Users.Find(order.UserId);
                    if (user != null)
                    {
                        user.Balance += order.Amount;
                    }
                    order.Status = "Approved";
                    order.ApproveTime = DateTime.Now;
                    db.SaveChanges();
                    ShowMessage($"充值订单 #{orderId} 已通过，用户余额增加 ¥{order.Amount:N2}");
                }
                else if (e.CommandName == "Reject")
                {
                    order.Status = "Rejected";
                    order.ApproveTime = DateTime.Now;
                    db.SaveChanges();
                    ShowMessage($"充值订单 #{orderId} 已拒绝", true);
                }
            }

            // 刷新后保留当前筛选状态
            string redirectUrl = $"AdminRecharge.aspx?page=1&status={ddlStatus.SelectedValue}";
            Response.Redirect(redirectUrl, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private void ShowMessage(string msg, bool isError = false)
        {
            string script = $"showToast('{(isError ? "❌ " : "✅ ")}{msg.Replace("'", "\\'")}', {isError.ToString().ToLower()});";
            ClientScript.RegisterStartupScript(GetType(), Guid.NewGuid().ToString(), script, true);
        }

        public class PageLink
        {
            public string Text { get; set; }
            public string Url { get; set; }
            public string CssClass { get; set; }
        }
    }
}