using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using deltatata.Models;

namespace DeltaTradeHub
{
    public partial class ItemDetail : Page
    {
        private DeltaTradeHubDBEntities db = new DeltaTradeHubDBEntities();
        private int CurrentUserId => Session["UserId"] != null ? (int)Session["UserId"] : 0;
        private int itemId = 0;
        private int pageSize = 10;
        private int currentPage = 1;
        private string sortBy = "price_asc";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!int.TryParse(Request.QueryString["id"], out itemId) || itemId == 0)
            {
                Response.Redirect("Marketplace.aspx");
                return;
            }

            if (!IsPostBack)
            {
                int.TryParse(Request.QueryString["page"], out currentPage);
                if (currentPage < 1) currentPage = 1;
                sortBy = Request.QueryString["sort"] ?? "price_asc";
                ddlSort.SelectedValue = sortBy;

                LoadItemInfo();
                LoadPriceRanges();
                LoadListings();
            }
        }

        private void LoadItemInfo()
        {
            var item = db.Items.Find(itemId);
            if (item == null) return;
            litItemName.Text = item.ItemName;
            litFullName.Text = $"{item.ItemName}（{GetWearText(item.Rarity)}）";
            litRarity.Text = GetWearText(item.Rarity);
            var category = db.Categories.Find(item.CategoryId);
            litCategory.Text = category?.CategoryName ?? "未分类";
            // 修复：HtmlImage 控件使用 Src 属性
            imgItem.Src = string.IsNullOrEmpty(item.ImageUrl) ? "/img/items/default.png" : item.ImageUrl;
        }

        private void LoadPriceRanges()
        {
            // 先查询出需要的原始数据（Rarity 和 Price），避免 LINQ to Entities 无法识别 GetWearText
            var rawData = (from l in db.Listings
                           join i in db.Items on l.ItemId equals i.ItemId
                           where l.ItemId == itemId && l.Status == "Active" && l.Quantity > 0
                           select new { i.Rarity, l.Price }).ToList();

            // 在内存中分组并转换磨损度
            var priceGroups = rawData
                .GroupBy(x => x.Rarity)
                .Select(g => new { Wear = GetWearText(g.Key), MinPrice = g.Min(x => x.Price) })
                .ToList();

            if (priceGroups.Any())
            {
                priceRangePanel.Controls.Clear();
                foreach (var group in priceGroups)
                {
                    var div = new Literal();
                    div.Text = $@"
                        <div class='price-item'>
                            <div class='price-wear'>{group.Wear}</div>
                            <div class='price-value'>¥{group.MinPrice:N2}</div>
                        </div>";
                    priceRangePanel.Controls.Add(div);
                }
            }
            else
            {
                priceRangePanel.Controls.Add(new Literal { Text = "<div class='price-item'>暂无报价</div>" });
            }
        }

        private void LoadListings()
        {
            // 先查询出原始数据（卖家名称、价格、Rarity 等）
            var rawListings = (from l in db.Listings
                               join u in db.Users on l.UserId equals u.UserId
                               join i in db.Items on l.ItemId equals i.ItemId
                               where l.ItemId == itemId && l.Status == "Active" && l.Quantity > 0
                               select new
                               {
                                   l.ListingId,
                                   l.Price,
                                   l.CreateDate,
                                   SellerName = u.Username,
                                   WearRarity = i.Rarity
                               }).ToList();

            // 排序（在内存中进行）
            if (sortBy == "price_asc")
                rawListings = rawListings.OrderBy(x => x.Price).ToList();
            else
                rawListings = rawListings.OrderByDescending(x => x.Price).ToList();

            int totalCount = rawListings.Count;
            int totalPages = (int)Math.Ceiling((double)totalCount / pageSize);
            if (currentPage > totalPages && totalPages > 0) currentPage = totalPages;
            if (currentPage < 1) currentPage = 1;

            var pagedListings = rawListings
                .Skip((currentPage - 1) * pageSize)
                .Take(pageSize)
                .ToList();

            // 转换为前端展示需要的格式（添加磨损度文字和随机磨损值）
            var displayListings = pagedListings.Select(x => new
            {
                x.ListingId,
                x.Price,
                Wear = GetWearText(x.WearRarity),
                WearValue = "0." + new Random().Next(100, 999),
                x.SellerName,
                x.CreateDate
            }).ToList();

            if (displayListings.Any())
            {
                rptListings.DataSource = displayListings;
                rptListings.DataBind();
                litListingCount.Text = totalCount.ToString();
                litNoListings.Visible = false;
                BuildPagination(totalPages);
            }
            else
            {
                litNoListings.Visible = true;
                paginationDiv.Visible = false;
                litListingCount.Text = "0";
            }
        }

        private void BuildPagination(int totalPages)
        {
            if (totalPages <= 1)
            {
                paginationDiv.Visible = false;
                return;
            }
            paginationDiv.Visible = true;
            var pageLinks = new List<PageLink>();
            for (int i = 1; i <= totalPages; i++)
            {
                string url = $"?id={itemId}&page={i}&sort={sortBy}";
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

        protected void ddlSort_SelectedIndexChanged(object sender, EventArgs e)
        {
            sortBy = ddlSort.SelectedValue;
            Response.Redirect($"ItemDetail.aspx?id={itemId}&sort={sortBy}");
        }

        protected void rptListings_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Buy")
            {
                int listingId = Convert.ToInt32(e.CommandArgument);
                BuyFromListing(listingId);
            }
        }

        private void BuyFromListing(int listingId)
        {
            if (CurrentUserId == 0)
            {
                ShowMessage("请先登录", true);
                return;
            }

            var listing = db.Listings.Find(listingId);
            if (listing == null || listing.Status != "Active" || listing.Quantity <= 0)
            {
                ShowMessage("该商品已下架或已售出", true);
                return;
            }

            var seller = db.Users.Find(listing.UserId);
            var buyer = db.Users.Find(CurrentUserId);
            if (buyer.Balance < listing.Price)
            {
                ShowMessage($"余额不足，当前余额：{buyer.Balance:C}", true);
                return;
            }

            using (var trans = db.Database.BeginTransaction())
            {
                try
                {
                    seller.Balance += listing.Price;
                    buyer.Balance -= listing.Price;
                    listing.Quantity -= 1;
                    if (listing.Quantity == 0) listing.Status = "Sold";

                    var inv = db.Inventory.FirstOrDefault(i => i.UserId == CurrentUserId && i.ItemId == listing.ItemId);
                    if (inv != null) inv.Quantity += 1;
                    else
                    {
                        db.Inventory.Add(new Inventory
                        {
                            UserId = CurrentUserId,
                            ItemId = listing.ItemId,
                            Quantity = 1,
                            AcquireDate = DateTime.Now
                        });
                    }

                    db.Transactions.Add(new Transactions
                    {
                        UserId = CurrentUserId,
                        ItemId = listing.ItemId,
                        Quantity = 1,
                        UnitPrice = listing.Price,
                        TotalAmount = listing.Price,
                        TransactionDate = DateTime.Now,
                        Status = "Completed"
                    });

                    db.SaveChanges();
                    trans.Commit();
                    Session["Balance"] = buyer.Balance;
                    ShowMessage("购买成功！");
                    Response.Redirect(Request.RawUrl);
                }
                catch (Exception ex)
                {
                    trans.Rollback();
                    ShowMessage($"购买失败：{ex.Message}", true);
                }
            }
        }

        protected void btnSell_Click(object sender, EventArgs e)
        {
            Response.Redirect($"Storehouse.aspx?itemId={itemId}&action=sell");
        }

        protected void btnBuyNow_Click(object sender, EventArgs e)
        {
            Response.Redirect($"BuyOrders.aspx?itemId={itemId}");
        }

        private string GetWearText(string rarity)
        {
            if (string.IsNullOrEmpty(rarity)) return "普通";
            switch (rarity.ToLower())
            {
                case "factory_new": return "崭新出厂";
                case "minimal_wear": return "略有磨损";
                case "field_tested": return "久经沙场";
                case "well_worn": return "破损不堪";
                case "battle_scarred": return "战痕累累";
                default: return rarity;
            }
        }

        private void ShowMessage(string msg, bool isError = false)
        {
            string script = $"alert('{(isError ? "❌ " : "✅ ")}{msg.Replace("'", "\\'")}');";
            ClientScript.RegisterStartupScript(GetType(), "toast", script, true);
        }

        public class PageLink
        {
            public string Text { get; set; }
            public string Url { get; set; }
            public string CssClass { get; set; }
        }
    }
}