using deltatata.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DeltaTradeHub
{
    public partial class Marketplace : Page
    {
        private DeltaTradeHubDBEntities db = new DeltaTradeHubDBEntities();
        private int CurrentUserId => Session["UserId"] != null ? (int)Session["UserId"] : 0;
        private int pageSize = 20;
        private int currentPage = 1;

        // 筛选参数
        private int? categoryId = null;
        private string quality = null;
        private string keyword = null;
        private string sortBy = "time_desc";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (CurrentUserId == 0)
            {
                Response.Redirect("Auth.aspx");
                return;
            }

            // 处理购买和加购 PostBack
            if (Request["__EVENTTARGET"] == "Buy")
            {
                int itemId = Convert.ToInt32(Request["__EVENTARGUMENT"]);
                DirectPurchase(itemId);
                return;
            }
            if (Request["__EVENTTARGET"] == "Cart")
            {
                int itemId = Convert.ToInt32(Request["__EVENTARGUMENT"]);
                AddToCart(itemId);
                return;
            }

            if (!IsPostBack)
            {
                // 获取 URL 参数
                if (int.TryParse(Request.QueryString["cat"], out int cat))
                    categoryId = cat;
                quality = Request.QueryString["quality"];
                keyword = Request.QueryString["keyword"];
                sortBy = Request.QueryString["sort"] ?? "time_desc";
                int.TryParse(Request.QueryString["page"], out currentPage);
                if (currentPage < 1) currentPage = 1;

                // 绑定分类
                LoadCategories();
                // 加载商品
                LoadItems();
            }
            else
            {
                // 从 ViewState 恢复筛选条件
                if (ViewState["categoryId"] != null) categoryId = (int?)ViewState["categoryId"];
                quality = ViewState["quality"] as string;
                keyword = ViewState["keyword"] as string;
                sortBy = ViewState["sortBy"] as string;
                currentPage = ViewState["currentPage"] != null ? (int)ViewState["currentPage"] : 1;
            }
        }

        private void LoadCategories()
        {
            var categories = db.Categories.ToList();
            rptCategories.DataSource = categories;
            rptCategories.DataBind();
        }

        private void LoadItems()
        {
            var query = db.Items.Where(i => i.IsAvailable == true && i.Stock > 0);

            if (categoryId.HasValue)
                query = query.Where(i => i.CategoryId == categoryId.Value);
            if (!string.IsNullOrEmpty(quality))
                query = query.Where(i => i.Rarity == quality);
            if (!string.IsNullOrEmpty(keyword))
                query = query.Where(i => i.ItemName.Contains(keyword) || i.Description.Contains(keyword));

            // 排序
            switch (sortBy)
            {
                case "price_asc":
                    query = query.OrderBy(i => i.Price);
                    break;
                case "price_desc":
                    query = query.OrderByDescending(i => i.Price);
                    break;
                default:
                    query = query.OrderByDescending(i => i.CreateDate);
                    break;
            }

            int totalCount = query.Count();
            if (totalCount == 0)
            {
                // 无数据时直接清空列表并显示提示
                rptItems.DataSource = null;
                rptItems.DataBind();
                litNoData.Visible = true;
                rptPagination.Visible = false;
                return;
            }

            int totalPages = (int)Math.Ceiling((double)totalCount / pageSize);
            if (currentPage > totalPages) currentPage = totalPages;
            if (currentPage < 1) currentPage = 1;  // 关键修复

            var items = query.Skip((currentPage - 1) * pageSize).Take(pageSize).ToList();

            if (items.Any())
            {
                rptItems.DataSource = items;
                rptItems.DataBind();
                litNoData.Visible = false;
            }
            else
            {
                litNoData.Visible = true;
            }

            // 保存筛选状态供回发时使用
            ViewState["categoryId"] = categoryId;
            ViewState["quality"] = quality;
            ViewState["keyword"] = keyword;
            ViewState["sortBy"] = sortBy;
            ViewState["currentPage"] = currentPage;

            BuildPagination(totalPages);
        }

        private void BuildPagination(int totalPages)
        {
            if (totalPages <= 1)
            {
                rptPagination.Visible = false;
                return;
            }
            rptPagination.Visible = true;
            var pageLinks = new List<PageLink>();
            for (int i = 1; i <= totalPages; i++)
            {
                string url = $"?page={i}";
                if (categoryId.HasValue) url += $"&cat={categoryId}";
                if (!string.IsNullOrEmpty(quality)) url += $"&quality={quality}";
                if (!string.IsNullOrEmpty(keyword)) url += $"&keyword={System.Web.HttpUtility.UrlEncode(keyword)}";
                if (!string.IsNullOrEmpty(sortBy)) url += $"&sort={sortBy}";
                pageLinks.Add(new PageLink
                {
                    Text = i.ToString(),
                    Url = url,
                    CssClass = i == currentPage ? "current-page" : ""
                });
            }
            rptPagination.DataSource = pageLinks;
            rptPagination.DataBind();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            keyword = txtKeyword.Text.Trim();
            string url = "Marketplace.aspx?";
            if (!string.IsNullOrEmpty(keyword)) url += $"keyword={System.Web.HttpUtility.UrlEncode(keyword)}&";
            if (categoryId.HasValue) url += $"cat={categoryId}&";
            if (!string.IsNullOrEmpty(quality)) url += $"quality={quality}&";
            if (!string.IsNullOrEmpty(sortBy)) url += $"sort={sortBy}";
            Response.Redirect(url.TrimEnd('&'));
        }

        protected void ddlSort_SelectedIndexChanged(object sender, EventArgs e)
        {
            sortBy = ddlSort.SelectedValue;
            string url = "Marketplace.aspx?";
            if (!string.IsNullOrEmpty(keyword)) url += $"keyword={System.Web.HttpUtility.UrlEncode(keyword)}&";
            if (categoryId.HasValue) url += $"cat={categoryId}&";
            if (!string.IsNullOrEmpty(quality)) url += $"quality={quality}&";
            url += $"sort={sortBy}";
            Response.Redirect(url.TrimEnd('&'));
        }

        private void DirectPurchase(int itemId)
        {
            var item = db.Items.Find(itemId);
            var user = db.Users.Find(CurrentUserId);
            if (item == null || user == null) { ShowMessage("商品不存在"); return; }
            if (item.Stock < 1) { ShowMessage("库存不足"); return; }
            if (user.Balance < item.Price) { ShowMessage($"余额不足，当前余额：{user.Balance:C}"); return; }

            try
            {
                user.Balance -= item.Price;
                item.Stock -= 1;

                var inv = db.Inventory.FirstOrDefault(i => i.UserId == CurrentUserId && i.ItemId == itemId);
                if (inv != null) inv.Quantity += 1;
                else
                {
                    db.Inventory.Add(new Inventory
                    {
                        UserId = CurrentUserId,
                        ItemId = itemId,
                        Quantity = 1,
                        AcquireDate = DateTime.Now
                    });
                }

                db.Transactions.Add(new Transactions
                {
                    UserId = CurrentUserId,
                    ItemId = itemId,
                    Quantity = 1,
                    UnitPrice = item.Price,
                    TotalAmount = item.Price,
                    TransactionDate = DateTime.Now,
                    Status = "Completed"
                });

                db.SaveChanges();
                Session["Balance"] = user.Balance;
                ShowMessage("购买成功！");
                Response.Redirect(Request.RawUrl);
            }
            catch (Exception ex)
            {
                ShowMessage($"购买失败：{ex.Message}");
            }
        }

        private void AddToCart(int itemId)
        {
            var item = db.Items.Find(itemId);
            if (item == null || item.Stock < 1) { ShowMessage("库存不足"); return; }

            var cartItem = db.Cart.FirstOrDefault(c => c.UserId == CurrentUserId && c.ItemId == itemId);
            if (cartItem != null)
            {
                if (cartItem.Quantity + 1 > item.Stock) { ShowMessage("已达库存上限"); return; }
                cartItem.Quantity += 1;
            }
            else
            {
                db.Cart.Add(new Cart
                {
                    UserId = CurrentUserId,
                    ItemId = itemId,
                    Quantity = 1,
                    AddDate = DateTime.Now
                });
            }
            db.SaveChanges();
            ShowMessage("已加入购物车");
        }

        // 磨损度转换方法
        protected string GetWearText(string rarity)
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

        private void ShowMessage(string msg)
        {
            ClientScript.RegisterStartupScript(this.GetType(), "toast", $"alert('{msg}');", true);
        }

        public class PageLink
        {
            public string Text { get; set; }
            public string Url { get; set; }
            public string CssClass { get; set; }
        }
    }
}