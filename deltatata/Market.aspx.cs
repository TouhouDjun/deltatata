using deltatata.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DeltaTradeHub
{
    public partial class Market : Page
    {
        private DeltaTradeHubDBEntities db = new DeltaTradeHubDBEntities();
        private int CurrentUserId => Session["UserId"] != null ? (int)Session["UserId"] : 0;
        private int hotPage = 1, newPage = 1, buyPage = 1;
        private const int pageSize = 8;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (CurrentUserId == 0)
            {
                Response.Redirect("Auth.aspx");
                return;
            }

            if (!IsPostBack)
            {
                int.TryParse(Request.QueryString["hotpage"], out hotPage);
                int.TryParse(Request.QueryString["newpage"], out newPage);
                int.TryParse(Request.QueryString["buypage"], out buyPage);
                hotPage = hotPage < 1 ? 1 : hotPage;
                newPage = newPage < 1 ? 1 : newPage;
                buyPage = buyPage < 1 ? 1 : buyPage;

                LoadHotItems();
                LoadNewItems();
                LoadBuyOrders();
            }
        }

        #region 数据加载
        private void LoadHotItems()
        {
            var query = db.Items.Where(i => i.IsAvailable == true && i.Stock > 0).OrderByDescending(i => i.Price);
            int totalCount = query.Count();
            int totalPages = (int)Math.Ceiling((double)totalCount / pageSize);
            if (hotPage > totalPages) hotPage = totalPages;
            var hotItems = query.Skip((hotPage - 1) * pageSize).Take(pageSize).ToList();
            rptHotItems.DataSource = hotItems;
            rptHotItems.DataBind();
            BuildPagination(rptHotPagination, totalPages, hotPage, "hotpage");
        }

        private void LoadNewItems()
        {
            var query = db.Items.Where(i => i.IsAvailable == true && i.Stock > 0).OrderByDescending(i => i.CreateDate);
            int totalCount = query.Count();
            int totalPages = (int)Math.Ceiling((double)totalCount / pageSize);
            if (newPage > totalPages) newPage = totalPages;
            var newItems = query.Skip((newPage - 1) * pageSize).Take(pageSize).ToList();
            rptNewItems.DataSource = newItems;
            rptNewItems.DataBind();
            BuildPagination(rptNewPagination, totalPages, newPage, "newpage");
        }

        private void LoadBuyOrders()
        {
            var query = from b in db.BuyOrders
                        join i in db.Items on b.ItemId equals i.ItemId
                        where b.Status == "Active" && b.UserId != CurrentUserId
                        select new { b.OrderId, b.ItemId, i.ItemName, i.ImageUrl, b.Quantity, b.Price, b.CreateDate };
            int totalCount = query.Count();
            int totalPages = (int)Math.Ceiling((double)totalCount / pageSize);
            if (buyPage > totalPages) buyPage = totalPages;
            var buyOrders = query.OrderByDescending(o => o.CreateDate).Skip((buyPage - 1) * pageSize).Take(pageSize).ToList();
            rptBuyOrders.DataSource = buyOrders;
            rptBuyOrders.DataBind();
            BuildPagination(rptBuyPagination, totalPages, buyPage, "buypage");
        }

        private void BuildPagination(Repeater repeater, int totalPages, int currentPage, string paramName)
        {
            var pageLinks = new List<PageLink>();
            int startPage = Math.Max(1, currentPage - 3);
            int endPage = Math.Min(totalPages, currentPage + 3);

            if (startPage > 1)
            {
                pageLinks.Add(CreatePageLink("1", $"?{paramName}=1", currentPage == 1));
                if (startPage > 2) pageLinks.Add(CreatePageLink("...", "", false, true));
            }
            for (int i = startPage; i <= endPage; i++)
            {
                string url = $"?{paramName}={i}";
                if (paramName != "hotpage") url += $"&hotpage={hotPage}";
                if (paramName != "newpage") url += $"&newpage={newPage}";
                if (paramName != "buypage") url += $"&buypage={buyPage}";
                pageLinks.Add(CreatePageLink(i.ToString(), url, i == currentPage));
            }
            if (endPage < totalPages)
            {
                if (endPage < totalPages - 1) pageLinks.Add(CreatePageLink("...", "", false, true));
                pageLinks.Add(CreatePageLink(totalPages.ToString(), $"?{paramName}={totalPages}", currentPage == totalPages));
            }
            repeater.DataSource = pageLinks;
            repeater.DataBind();
        }

        private PageLink CreatePageLink(string text, string url, bool isActive, bool isDisabled = false)
        {
            return new PageLink { Text = text, Url = url, CssClass = isActive ? "active" : (isDisabled ? "disabled" : "") };
        }
        #endregion

        #region 购买、加购、出售事件
        protected void DirectBuy_Click(object sender, EventArgs e)
        {
            Button btn = sender as Button;
            int itemId = Convert.ToInt32(btn.CommandArgument);
            PerformPurchase(itemId);
        }

        protected void AddToCart_Click(object sender, EventArgs e)
        {
            Button btn = sender as Button;
            int itemId = Convert.ToInt32(btn.CommandArgument);
            PerformAddToCart(itemId);
        }

        protected void SellToBuyOrder_Click(object sender, EventArgs e)
        {
            Button btn = sender as Button;
            int orderId = Convert.ToInt32(btn.CommandArgument);
            PerformSellToOrder(orderId);
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
                else db.Inventory.Add(new Inventory { UserId = CurrentUserId, ItemId = itemId, Quantity = 1, AcquireDate = DateTime.Now });

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
                db.Cart.Add(new Cart { UserId = CurrentUserId, ItemId = itemId, Quantity = 1, AddDate = DateTime.Now });
            }
            db.SaveChanges();
            ShowMessage("已加入购物车");
            // 修改：重定向时加上 ?cartOpen=1，让母版页自动弹出侧边栏
            Response.Redirect(Request.RawUrl + "?cartOpen=1");
        }

        private void PerformSellToOrder(int orderId)
        {
            var order = db.BuyOrders.Find(orderId);
            if (order == null || order.Status != "Active") { ShowMessage("求购单已失效"); return; }

            var sellerInv = db.Inventory.FirstOrDefault(i => i.UserId == CurrentUserId && i.ItemId == order.ItemId);
            if (sellerInv == null || sellerInv.Quantity < order.Quantity) { ShowMessage("您仓库中该物品数量不足"); return; }

            var buyer = db.Users.Find(order.UserId);
            var seller = db.Users.Find(CurrentUserId);
            decimal total = order.Price * order.Quantity;
            if (buyer.Balance < total) { ShowMessage("买家余额不足"); return; }

            try
            {
                buyer.Balance -= total;
                seller.Balance += total;
                sellerInv.Quantity -= order.Quantity;
                if (sellerInv.Quantity == 0) db.Inventory.Remove(sellerInv);

                var buyerInv = db.Inventory.FirstOrDefault(i => i.UserId == buyer.UserId && i.ItemId == order.ItemId);
                if (buyerInv != null) buyerInv.Quantity += order.Quantity;
                else db.Inventory.Add(new Inventory { UserId = buyer.UserId, ItemId = order.ItemId, Quantity = order.Quantity, AcquireDate = DateTime.Now });

                db.Transactions.Add(new Transactions
                {
                    UserId = buyer.UserId,
                    ItemId = order.ItemId,
                    Quantity = order.Quantity,
                    UnitPrice = order.Price,
                    TotalAmount = total,
                    TransactionDate = DateTime.Now,
                    Status = "Completed"
                });
                order.Status = "Filled";
                db.SaveChanges();
                Session["Balance"] = seller.Balance;
                ShowMessage("出售成功");
                Response.Redirect(Request.RawUrl);
            }
            catch (Exception ex)
            {
                ShowMessage($"出售失败：{ex.Message}");
            }
        }
        #endregion

        #region 辅助方法
        protected string GetWearText(string rarity)
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

        protected string GetWearDesc(string rarity) => GetWearText(rarity);

        private void ShowMessage(string msg)
        {
            string script = $"alert('{msg.Replace("'", "\\'")}');";
            ClientScript.RegisterStartupScript(GetType(), "toast", script, true);
        }
        #endregion

        public class PageLink
        {
            public string Text { get; set; }
            public string Url { get; set; }
            public string CssClass { get; set; }
        }
    }
}