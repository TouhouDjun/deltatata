using deltatata.Models;
using System;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DeltaTradeHub
{
    public partial class NewsDetail : Page
    {
        private DeltaTradeHubDBEntities db = new DeltaTradeHubDBEntities();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                int newsId = 0;
                if (int.TryParse(Request.QueryString["id"], out newsId))
                {
                    LoadNews(newsId);
                }
                else
                {
                    // 无效 ID，重定向到列表页
                    Response.Redirect("News.aspx");
                }
            }
        }

        private void LoadNews(int newsId)
        {
            var news = db.News.FirstOrDefault(n => n.NewsId == newsId);
            if (news == null)
            {
                Response.Redirect("News.aspx");
                return;
            }

            litTitle.Text = news.Title;
            litCategory.Text = news.Category;
            litAuthor.Text = news.Author;
            litSource.Text = news.Source;
            litDate.Text = news.PublishDate.ToString("yyyy-MM-dd");

            // 正文处理：若 Content 为空则显示摘要，否则显示完整内容（保留换行）
            string contentHtml = !string.IsNullOrEmpty(news.Content) ? news.Content : news.Summary;
            // 替换换行为 <br> 方便显示
            contentHtml = contentHtml.Replace("\r\n", "<br>").Replace("\n", "<br>");
            litContent.Text = $"<div class='article-content'>{contentHtml}</div>";

            // 如果有图片，显示图片
            if (!string.IsNullOrEmpty(news.ImageUrl))
            {
                imgNews.ImageUrl = news.ImageUrl;
                imgNews.Visible = true;
            }

            // 上一篇/下一篇（按发布日期倒序排列）
            var allNews = db.News.OrderByDescending(n => n.PublishDate).ToList();
            int currentIndex = allNews.FindIndex(n => n.NewsId == newsId);
            if (currentIndex > 0)
            {
                int prevId = allNews[currentIndex - 1].NewsId;
                lnkPrev.NavigateUrl = $"NewsDetail.aspx?id={prevId}";
                lnkPrev.CssClass = "nav-link";
            }
            else
            {
                lnkPrev.Text = "已是第一篇";
                lnkPrev.CssClass = "nav-link disabled-nav";
                lnkPrev.NavigateUrl = "#";
            }

            if (currentIndex < allNews.Count - 1)
            {
                int nextId = allNews[currentIndex + 1].NewsId;
                lnkNext.NavigateUrl = $"NewsDetail.aspx?id={nextId}";
                lnkNext.CssClass = "nav-link";
            }
            else
            {
                lnkNext.Text = "已是最后一篇";
                lnkNext.CssClass = "nav-link disabled-nav";
                lnkNext.NavigateUrl = "#";
            }
        }
    }
}