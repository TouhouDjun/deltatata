using System;
using System.Web.UI;
using deltatata.Models;

namespace DeltaTradeHub
{
    public partial class PostArticle : Page
    {
        private DeltaTradeHubDBEntities db = new DeltaTradeHubDBEntities();
        private int CurrentUserId => Session["UserId"] != null ? (int)Session["UserId"] : 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (CurrentUserId == 0)
            {
                Response.Redirect("Auth.aspx");
                return;
            }

            if (!IsPostBack)
            {
                // 预填作者为当前登录用户名
                var user = db.Users.Find(CurrentUserId);
                if (user != null)
                {
                    txtAuthor.Text = user.Username;
                }
            }
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string title = txtTitle.Text.Trim();
            string category = ddlCategory.SelectedValue;
            string author = txtAuthor.Text.Trim();
            string source = txtSource.Text.Trim();
            string content = txtContent.Text.Trim();
            string imageUrl = txtImageUrl.Text.Trim();

            // 简单验证
            if (string.IsNullOrEmpty(title) || string.IsNullOrEmpty(content))
            {
                ShowMessage("标题和正文不能为空", true);
                return;
            }

            // 摘要取正文前150个字符
            string summary = content.Length > 150 ? content.Substring(0, 150) + "..." : content;
            summary = summary.Replace("\r\n", " ").Replace("\n", " ");

            // 图片URL默认处理
            if (string.IsNullOrEmpty(imageUrl))
            {
                imageUrl = "/img/items/default.png";
            }

            var news = new deltatata.Models.News
            {
                Title = title,
                Category = category,
                Author = author,
                Source = source,
                PublishDate = DateTime.Now,
                Summary = summary,
                Content = content,
                ImageUrl = imageUrl,
                ViewCount = 0,
                IsTop = false,
                CreateDate = DateTime.Now
            };

            db.News.Add(news);
            db.SaveChanges();

            // 显示成功面板
            pnlForm.Visible = false;
            pnlSuccess.Visible = true;
        }

        private void ShowMessage(string msg, bool isError = false)
        {
            string script = $"alert('{(isError ? "❌ " : "✅ ")}{msg.Replace("'", "\\'")}');";
            ClientScript.RegisterStartupScript(GetType(), "toast", script, true);
        }
    }
}