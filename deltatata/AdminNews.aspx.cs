using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using deltatata.Models;

namespace DeltaTradeHub
{
    public partial class AdminNews : Page
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
                    txtSearch.Text = search;
                string cat = Request.QueryString["cat"];
                if (!string.IsNullOrEmpty(cat))
                    ddlCategory.SelectedValue = cat;

                int.TryParse(Request.QueryString["page"], out currentPage);
                if (currentPage < 1) currentPage = 1;
                LoadNews();
            }
        }

        private void LoadNews()
        {
            var query = db.News.AsQueryable();

            // 搜索关键字（标题或作者）
            string keyword = txtSearch.Text.Trim();
            if (!string.IsNullOrEmpty(keyword))
                query = query.Where(n => n.Title.Contains(keyword) || n.Author.Contains(keyword));

            // 分类筛选
            string category = ddlCategory.SelectedValue;
            if (!string.IsNullOrEmpty(category))
                query = query.Where(n => n.Category == category);

            int totalCount = query.Count();
            int totalPages = (int)Math.Ceiling((double)totalCount / pageSize);
            if (currentPage > totalPages && totalPages > 0) currentPage = totalPages;

            var news = query
                .OrderByDescending(n => n.IsTop)
                .ThenByDescending(n => n.PublishDate)
                .Skip((currentPage - 1) * pageSize)
                .Take(pageSize)
                .Select(n => new
                {
                    n.NewsId,
                    n.Title,
                    n.Category,
                    n.Author,
                    n.PublishDate,
                    n.IsTop
                }).ToList();

            if (news.Any())
            {
                rptNews.DataSource = news;
                rptNews.DataBind();
                BuildPagination(totalPages);
                paginationDiv.Visible = true;
            }
            else
            {
                paginationDiv.Visible = false;
                rptNews.DataSource = null;
                rptNews.DataBind();
            }
        }

        private void BuildPagination(int totalPages)
        {
            if (totalPages <= 1) { paginationDiv.Visible = false; return; }
            var pageLinks = new List<PageLink>();
            for (int i = 1; i <= totalPages; i++)
            {
                string url = $"?page={i}";
                if (!string.IsNullOrEmpty(txtSearch.Text))
                    url += $"&search={Uri.EscapeDataString(txtSearch.Text)}";
                if (!string.IsNullOrEmpty(ddlCategory.SelectedValue))
                    url += $"&cat={ddlCategory.SelectedValue}";
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
            string url = "AdminNews.aspx?page=1";
            if (!string.IsNullOrEmpty(txtSearch.Text))
                url += $"&search={Uri.EscapeDataString(txtSearch.Text)}";
            if (!string.IsNullOrEmpty(ddlCategory.SelectedValue))
                url += $"&cat={ddlCategory.SelectedValue}";
            Response.Redirect(url);
        }

        protected void rptNews_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int newsId = Convert.ToInt32(e.CommandArgument);
            if (e.CommandName == "Delete")
            {
                var news = db.News.Find(newsId);
                if (news != null)
                {
                    db.News.Remove(news);
                    db.SaveChanges();
                }
                Response.Redirect(Request.RawUrl);
            }
            else if (e.CommandName == "ToggleTop")
            {
                var news = db.News.Find(newsId);
                if (news != null)
                {
                    news.IsTop = !news.IsTop;
                    db.SaveChanges();
                }
                Response.Redirect(Request.RawUrl);
            }
        }

        [WebMethod(EnableSession = true)]
        public static object GetArticle(int id)
        {
            using (var ctx = new DeltaTradeHubDBEntities())
            {
                var article = ctx.News.Find(id);
                return article;
            }
        }

        [WebMethod(EnableSession = true)]
        public static object SaveArticle(dynamic data)
        {
            using (var ctx = new DeltaTradeHubDBEntities())
            {
                int id = data.id;
                string title = data.title;
                string category = data.category;
                string author = data.author;
                string source = data.source;
                string summary = data.summary;
                string content = data.content;
                string imageUrl = data.imageUrl;
                bool isTop = data.isTop;

                if (id == 0)
                {
                    var news = new deltatata.Models.News
                    {
                        Title = title,
                        Category = category,
                        Author = author,
                        Source = source,
                        Summary = summary,
                        Content = content,
                        ImageUrl = imageUrl,
                        IsTop = isTop,
                        PublishDate = DateTime.Now,
                        CreateDate = DateTime.Now,
                        ViewCount = 0
                    };
                    ctx.News.Add(news);
                    ctx.SaveChanges();
                    return new { success = true, message = "添加成功" };
                }
                else
                {
                    var news = ctx.News.Find(id);
                    if (news != null)
                    {
                        news.Title = title;
                        news.Category = category;
                        news.Author = author;
                        news.Source = source;
                        news.Summary = summary;
                        news.Content = content;
                        news.ImageUrl = imageUrl;
                        news.IsTop = isTop;
                        ctx.SaveChanges();
                        return new { success = true, message = "修改成功" };
                    }
                    return new { success = false, message = "文章不存在" };
                }
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