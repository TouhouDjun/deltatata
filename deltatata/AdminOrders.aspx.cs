using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using deltatata.Models;

namespace DeltaTradeHub
{
    public partial class AdminOrders : Page
    {
        private DeltaTradeHubDBEntities db = new DeltaTradeHubDBEntities();
        private int pageSize = 10;
        private int currentPage = 1;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null || !(Session["IsAdmin"] is true))
            {
                Response.Redirect("Auth.aspx");
                return;
            }

            if (!IsPostBack)
            {
                // 从 URL 恢复搜索条件
                string search = Request.QueryString["search"];
                if (!string.IsNullOrEmpty(search))
                    txtKeyword.Text = search;
                string status = Request.QueryString["status"];
                if (!string.IsNullOrEmpty(status))
                    ddlStatus.SelectedValue = status;

                int.TryParse(Request.QueryString["page"], out currentPage);
                if (currentPage < 1) currentPage = 1;
                LoadOrders();
            }
            else
            {
                // 非首次加载时也获取控件值（保留）
            }
        }

        private void LoadOrders()
        {
            // 使用 Join 查询
            var query = from t in db.Transactions
                        join i in db.Items on t.ItemId equals i.ItemId
                        join u in db.Users on t.UserId equals u.UserId
                        select new
                        {
                            t.TransactionId,
                            t.ItemId,
                            t.Quantity,
                            t.UnitPrice,
                            t.TotalAmount,
                            t.Status,
                            t.TransactionDate,
                            ItemName = i.ItemName,
                            Username = u.Username
                        };

            // 关键字搜索（商品名称或用户名）
            string keyword = txtKeyword.Text.Trim();
            if (!string.IsNullOrEmpty(keyword))
            {
                query = query.Where(t => t.ItemName.Contains(keyword) || t.Username.Contains(keyword));
            }

            // 状态筛选
            string status = ddlStatus.SelectedValue;
            if (!string.IsNullOrEmpty(status))
            {
                query = query.Where(t => t.Status == status);
            }

            int totalCount = query.Count();
            int totalPages = (int)Math.Ceiling((double)totalCount / pageSize);
            if (currentPage > totalPages && totalPages > 0) currentPage = totalPages;

            var orders = query
                .OrderByDescending(t => t.TransactionDate)
                .Skip((currentPage - 1) * pageSize)
                .Take(pageSize)
                .ToList();

            if (orders.Any())
            {
                rptOrders.DataSource = orders;
                rptOrders.DataBind();
                BuildPagination(totalPages);
                paginationDiv.Visible = true;
            }
            else
            {
                paginationDiv.Visible = false;
                rptOrders.DataSource = null;
                rptOrders.DataBind();
            }
        }

        private void BuildPagination(int totalPages)
        {
            if (totalPages <= 1) { paginationDiv.Visible = false; return; }
            var pageLinks = new List<PageLink>();
            for (int i = 1; i <= totalPages; i++)
            {
                string url = $"?page={i}";
                if (!string.IsNullOrEmpty(txtKeyword.Text))
                    url += $"&search={Uri.EscapeDataString(txtKeyword.Text)}";
                if (!string.IsNullOrEmpty(ddlStatus.SelectedValue))
                    url += $"&status={ddlStatus.SelectedValue}";
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
            string url = "AdminOrders.aspx?page=1";
            if (!string.IsNullOrEmpty(txtKeyword.Text))
                url += $"&search={Uri.EscapeDataString(txtKeyword.Text)}";
            if (!string.IsNullOrEmpty(ddlStatus.SelectedValue))
                url += $"&status={ddlStatus.SelectedValue}";
            Response.Redirect(url);
        }

        // 状态样式辅助方法
        public string GetStatusClass(string status)
        {
            switch (status)
            {
                case "Completed": return "approved";
                case "Pending": return "pending";
                case "Cancelled": return "rejected";
                default: return "pending";
            }
        }

        public class PageLink
        {
            public string Text { get; set; }
            public string Url { get; set; }
            public string CssClass { get; set; }
        }
    }
}