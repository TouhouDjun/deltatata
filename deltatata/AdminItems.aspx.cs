using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using deltatata.Models;

namespace DeltaTradeHub
{
    public partial class AdminItems : Page
    {
        private DeltaTradeHubDBEntities db = new DeltaTradeHubDBEntities();
        private int pageSize = 10;
        private int currentPage = 1;

        // 存储筛选条件，以便在LoadItems中使用
        private string searchName = "";
        private string searchCategory = "";
        private string searchStatus = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null || !(Session["IsAdmin"] is true))
            {
                Response.Redirect("Auth.aspx");
                return;
            }

            if (!IsPostBack)
            {
                // 绑定分类筛选下拉框（服务器端）
                var categories = db.Categories.ToList();
                ddlCategory.DataSource = categories;
                ddlCategory.DataTextField = "CategoryName";
                ddlCategory.DataValueField = "CategoryId";
                ddlCategory.DataBind();
                ddlCategory.Items.Insert(0, new ListItem("全部分类", ""));

                // 从 URL 获取筛选参数，并同步到控件
                searchName = Request.QueryString["name"] ?? "";
                searchCategory = Request.QueryString["cat"] ?? "";
                searchStatus = Request.QueryString["status"] ?? "";

                txtName.Text = searchName;
                if (!string.IsNullOrEmpty(searchCategory))
                    ddlCategory.SelectedValue = searchCategory;
                if (!string.IsNullOrEmpty(searchStatus))
                    ddlStatus.SelectedValue = searchStatus;

                int.TryParse(Request.QueryString["page"], out currentPage);
                if (currentPage < 1) currentPage = 1;
                LoadItems();
            }
        }

        private void LoadItems()
        {
            var query = from i in db.Items
                        join c in db.Categories on i.CategoryId equals c.CategoryId
                        select new
                        {
                            i.ItemId,
                            i.ItemName,
                            i.Price,
                            i.Stock,
                            i.Rarity,
                            i.ImageUrl,
                            i.IsAvailable,
                            i.Description,
                            CategoryName = c.CategoryName,
                            i.CategoryId
                        };

            // 搜索条件（使用从 URL 读取或控件保存的值）
            string name = txtName.Text.Trim();
            if (!string.IsNullOrEmpty(name))
                query = query.Where(x => x.ItemName.Contains(name));

            if (!string.IsNullOrEmpty(ddlCategory.SelectedValue) && ddlCategory.SelectedValue != "")
            {
                int catId = int.Parse(ddlCategory.SelectedValue);
                query = query.Where(x => x.CategoryId == catId);
            }

            if (ddlStatus.SelectedValue == "true")
                query = query.Where(x => x.IsAvailable == true);
            else if (ddlStatus.SelectedValue == "false")
                query = query.Where(x => x.IsAvailable == false);

            int totalCount = query.Count();
            int totalPages = (int)Math.Ceiling((double)totalCount / pageSize);
            if (currentPage > totalPages && totalPages > 0) currentPage = totalPages;

            var items = query
                .OrderByDescending(x => x.ItemId)
                .Skip((currentPage - 1) * pageSize)
                .Take(pageSize)
                .ToList()
                .Select(x => new
                {
                    x.ItemId,
                    x.ItemName,
                    x.CategoryName,
                    x.Price,
                    x.Stock,
                    RarityText = GetWearText(x.Rarity),
                    x.ImageUrl,
                    x.IsAvailable
                }).ToList();

            if (items.Any())
            {
                rptItems.DataSource = items;
                rptItems.DataBind();
                BuildPagination(totalPages);
            }
            else
            {
                rptItems.DataSource = null;
                rptItems.DataBind();
                paginationDiv.Visible = false;
            }
        }

        private void BuildPagination(int totalPages)
        {
            if (totalPages <= 1) { paginationDiv.Visible = false; return; }
            paginationDiv.Visible = true;
            var pageLinks = new List<PageLink>();
            for (int i = 1; i <= totalPages; i++)
            {
                string url = $"?page={i}";
                if (!string.IsNullOrEmpty(txtName.Text))
                    url += $"&name={Uri.EscapeDataString(txtName.Text)}";
                if (!string.IsNullOrEmpty(ddlCategory.SelectedValue) && ddlCategory.SelectedValue != "")
                    url += $"&cat={ddlCategory.SelectedValue}";
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
            string url = "AdminItems.aspx?page=1";
            if (!string.IsNullOrEmpty(txtName.Text))
                url += $"&name={Uri.EscapeDataString(txtName.Text)}";
            if (!string.IsNullOrEmpty(ddlCategory.SelectedValue) && ddlCategory.SelectedValue != "")
                url += $"&cat={ddlCategory.SelectedValue}";
            if (!string.IsNullOrEmpty(ddlStatus.SelectedValue))
                url += $"&status={ddlStatus.SelectedValue}";
            Response.Redirect(url);
        }

        protected void rptItems_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int itemId = Convert.ToInt32(e.CommandArgument);
            if (e.CommandName == "ToggleStatus")
            {
                var item = db.Items.Find(itemId);
                if (item != null)
                {
                    item.IsAvailable = !item.IsAvailable;
                    db.SaveChanges();
                }
                // 刷新当前页，保留筛选条件
                string url = $"AdminItems.aspx?page={currentPage}";
                if (!string.IsNullOrEmpty(txtName.Text))
                    url += $"&name={Uri.EscapeDataString(txtName.Text)}";
                if (!string.IsNullOrEmpty(ddlCategory.SelectedValue) && ddlCategory.SelectedValue != "")
                    url += $"&cat={ddlCategory.SelectedValue}";
                if (!string.IsNullOrEmpty(ddlStatus.SelectedValue))
                    url += $"&status={ddlStatus.SelectedValue}";
                Response.Redirect(url);
            }
            else if (e.CommandName == "Delete")
            {
                var item = db.Items.Find(itemId);
                if (item != null)
                {
                    // 检查是否有关联订单等，简单删除
                    db.Items.Remove(item);
                    db.SaveChanges();
                }
                Response.Redirect(Request.RawUrl);
            }
            // Edit 由前端 AJAX 处理，无需服务器跳转
        }

        [WebMethod(EnableSession = true)]
        public static List<CategoryDto> GetCategories()
        {
            using (var ctx = new DeltaTradeHubDBEntities())
            {
                return ctx.Categories.Select(c => new CategoryDto { CategoryId = c.CategoryId, CategoryName = c.CategoryName }).ToList();
            }
        }

        [WebMethod(EnableSession = true)]
        public static ItemDetailDto GetItem(int itemId)
        {
            using (var ctx = new DeltaTradeHubDBEntities())
            {
                var item = ctx.Items.Find(itemId);
                if (item == null) return null;
                return new ItemDetailDto
                {
                    ItemId = item.ItemId,
                    ItemName = item.ItemName,
                    CategoryId = item.CategoryId,
                    Price = item.Price,
                    Stock = item.Stock,
                    Rarity = item.Rarity,
                    ImageUrl = item.ImageUrl,
                    Description = item.Description
                };
            }
        }

        [WebMethod(EnableSession = true)]
        public static SimpleResult SaveItem(ItemDetailDto data)
        {
            try
            {
                using (var ctx = new DeltaTradeHubDBEntities())
                {
                    if (data.ItemId == 0)
                    {
                        var newItem = new Items
                        {
                            CategoryId = data.CategoryId,
                            ItemName = data.ItemName,
                            Description = data.Description ?? "",
                            Price = data.Price,
                            Stock = data.Stock,
                            Rarity = data.Rarity,
                            ImageUrl = data.ImageUrl ?? "/img/items/default.png",
                            CreateDate = DateTime.Now,
                            IsAvailable = true
                        };
                        ctx.Items.Add(newItem);
                    }
                    else
                    {
                        var item = ctx.Items.Find(data.ItemId);
                        if (item == null) return new SimpleResult { success = false, message = "商品不存在" };
                        item.CategoryId = data.CategoryId;
                        item.ItemName = data.ItemName;
                        item.Description = data.Description ?? "";
                        item.Price = data.Price;
                        item.Stock = data.Stock;
                        item.Rarity = data.Rarity;
                        item.ImageUrl = data.ImageUrl ?? "/img/items/default.png";
                    }
                    ctx.SaveChanges();
                    return new SimpleResult { success = true, message = "保存成功" };
                }
            }
            catch (Exception ex)
            {
                return new SimpleResult { success = false, message = ex.Message };
            }
        }

        private string GetWearText(string rarity)
        {
            switch (rarity?.ToLower())
            {
                case "factory_new": return "崭新出厂";
                case "minimal_wear": return "略有磨损";
                case "field_tested": return "久经沙场";
                case "well_worn": return "破损不堪";
                case "battle_scarred": return "战痕累累";
                default: return rarity ?? "普通";
            }
        }

        public class PageLink
        {
            public string Text { get; set; }
            public string Url { get; set; }
            public string CssClass { get; set; }
        }
        public class CategoryDto { public int CategoryId { get; set; } public string CategoryName { get; set; } }
        public class ItemDetailDto
        {
            public int ItemId { get; set; }
            public string ItemName { get; set; }
            public int CategoryId { get; set; }
            public decimal Price { get; set; }
            public int Stock { get; set; }
            public string Rarity { get; set; }
            public string ImageUrl { get; set; }
            public string Description { get; set; }
        }
        public class SimpleResult { public bool success { get; set; } public string message { get; set; } }
    }
}