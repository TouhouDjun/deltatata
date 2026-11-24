using deltatata.Models;
using System;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DeltaTradeHub
{
    public partial class News : Page
    {
        private DeltaTradeHubDBEntities db = new DeltaTradeHubDBEntities();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadNews();
            }
        }

        private void LoadNews()
        {
            var newsList = db.News.OrderByDescending(n => n.PublishDate).ToList();
            if (newsList.Any())
            {
                rptNews.DataSource = newsList;
                rptNews.DataBind();
                litNoData.Visible = false;
            }
            else
            {
                litNoData.Visible = true;
            }
        }
    }
}