using deltatata.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DeltaTradeHub
{
    public partial class HotItems : System.Web.UI.Page
    {
        private DeltaTradeHubDBEntities db = new DeltaTradeHubDBEntities();
        private int CurrentUserId => Session["UserId"] != null ? (int)Session["UserId"] : 0;
        private int pageSize = 12;
        private int currentPage = 1;

        public class PaginationModel
        {
            public string Url { get; set; }
            public string CssClass { get; set; }
            public string Text { get; set; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (CurrentUserId == 0) { Response.Redirect("Auth.aspx"); return; }

            if (!IsPostBack)
            {
                int.TryParse(Request.QueryString["page"], out currentPage);
                if (currentPage < 1) currentPage = 1;
                BindHotItems();
                BindPagination();
            }
        }

        private void BindHotItems()
        {
            try
            {
                var query = db.Items.Where(i => i.IsAvailable == true);
                int totalCount = query.Count();
                int totalPages = (int)Math.Ceiling((double)totalCount / pageSize);
                if (currentPage > totalPages && totalPages > 0) currentPage = totalPages;

                var hotItems = query.OrderByDescending(i => i.CreateDate)
                                    .Skip((currentPage - 1) * pageSize)
                                    .Take(pageSize)
                                    .Select(i => new { i.ItemId, i.ItemName, i.Price, i.Rarity, i.Stock, i.ImageUrl })
                                    .ToList();

                if (hotItems.Count == 0)
                {
                    litNoData.Visible = true;
                    rptHotItems.Visible = false;
                }
                else
                {
                    litNoData.Visible = false;
                    rptHotItems.Visible = true;
                    rptHotItems.DataSource = hotItems;
                    rptHotItems.DataBind();
                }
                ViewState["TotalPages"] = totalPages;
            }
            catch (Exception ex)
            {
                Response.Write($"加载失败：{ex.Message}");
            }
        }

        private void BindPagination()
        {
            int totalPages = ViewState["TotalPages"] != null ? (int)ViewState["TotalPages"] : 1;
            var paginationList = new List<PaginationModel>();
            for (int i = 1; i <= totalPages; i++)
            {
                paginationList.Add(new PaginationModel
                {
                    Url = $"{Request.Url.AbsolutePath}?page={i}",
                    CssClass = i == currentPage ? "active" : "",
                    Text = i.ToString()
                });
            }
            rptPagination.DataSource = paginationList;
            rptPagination.DataBind();
        }

        public string GetWearDesc(string rarity)
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

        protected void BuyItem_Click(object sender, EventArgs e)
        {
            Button btn = sender as Button;
            int itemId = Convert.ToInt32(btn.CommandArgument);
            PerformPurchase(itemId);
        }

        protected void AddCart_Click(object sender, EventArgs e)
        {
            Button btn = sender as Button;
            int itemId = Convert.ToInt32(btn.CommandArgument);
            PerformAddToCart(itemId);
        }

        private void PerformPurchase(int itemId)
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

        private void PerformAddToCart(int itemId)
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

        private void ShowMessage(string msg)
        {
            ClientScript.RegisterStartupScript(this.GetType(), "toast", $"alert('{msg}');", true);
        }
    }
}