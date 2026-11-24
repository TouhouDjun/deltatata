using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using deltatata.Models;

namespace DeltaTradeHub
{
    public partial class AdminUsers : Page
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
                // ✅ 关键：从URL读取搜索关键词，而不是从控件
                string searchKeyword = Request.QueryString["search"] ?? "";
                txtSearch.Text = searchKeyword; // 同步到文本框

                int.TryParse(Request.QueryString["page"], out int currentPage);
                if (currentPage < 1) currentPage = 1;

                LoadUsers(currentPage, searchKeyword);
            }
        }

        private void LoadUsers(int currentPage, string searchKeyword)
        {
            using (var db = new DeltaTradeHubDBEntities())
            {
                // ✅ 关键修复：显式声明为IQueryable类型
                IQueryable<Users> query = db.Users.AsNoTracking();

                if (!string.IsNullOrEmpty(searchKeyword))
                {
                    query = query.Where(u =>
                        u.Username.Contains(searchKeyword) ||
                        u.Email.Contains(searchKeyword));
                }

                int totalCount = query.Count();
                int totalPages = (int)Math.Ceiling((double)totalCount / pageSize);
                if (currentPage > totalPages && totalPages > 0) currentPage = totalPages;

                var users = query
                    .OrderBy(u => u.UserId)
                    .Skip((currentPage - 1) * pageSize)
                    .Take(pageSize)
                    .Select(u => new
                    {
                        u.UserId,
                        u.Username,
                        u.Email,
                        u.Balance,
                        u.RegisterDate,
                        u.IsActive
                    })
                    .ToList();

                rptUsers.DataSource = users;
                rptUsers.DataBind();

                if (users.Any())
                {
                    BuildPagination(totalPages, currentPage, searchKeyword);
                    paginationDiv.Visible = true;
                }
                else
                {
                    paginationDiv.Visible = false;
                }
            }
        }

        private void BuildPagination(int totalPages, int currentPage, string searchKeyword)
        {
            if (totalPages <= 1) { paginationDiv.Visible = false; return; }

            var pageLinks = new List<PageLink>();
            for (int i = 1; i <= totalPages; i++)
            {
                string url = $"?page={i}";
                if (!string.IsNullOrEmpty(searchKeyword))
                    url += $"&search={Uri.EscapeDataString(searchKeyword)}";

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
            // 直接跳转到带搜索参数的URL
            string url = "AdminUsers.aspx?page=1";
            if (!string.IsNullOrEmpty(txtSearch.Text.Trim()))
                url += $"&search={Uri.EscapeDataString(txtSearch.Text.Trim())}";

            Response.Redirect(url, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        protected void rptUsers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "ToggleStatus")
            {
                int userId = Convert.ToInt32(e.CommandArgument);

                using (var db = new DeltaTradeHubDBEntities())
                {
                    var user = db.Users.Find(userId);
                    if (user != null && user.Username != "admin1")
                    {
                        user.IsActive = !user.IsActive;
                        db.SaveChanges();
                    }
                }

                // 刷新当前页，保留搜索条件
                Response.Redirect(Request.RawUrl, false);
                Context.ApplicationInstance.CompleteRequest();
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