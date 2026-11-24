using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using deltatata.Models;   // 请根据您的项目实际命名空间调整

namespace DeltaTradeHub
{
    public partial class BuyOrders : Page
    {
        private DeltaTradeHubDBEntities db = new DeltaTradeHubDBEntities();
        private int CurrentUserId => Session["UserId"] != null ? (int)Session["UserId"] : 0;
        private int pageSize = 12;
        private int currentPage = 1;

        // 供前台 Repeater 调用的公共方法
        public int GetCurrentUserId() => CurrentUserId;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (CurrentUserId == 0)
            {
                Response.Redirect("Auth.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadItemsForDropdown();
                LoadBuyOrders();
            }
        }

        private void LoadItemsForDropdown()
        {
            var items = db.Items.Where(i => i.IsAvailable == true).Select(i => new { i.ItemId, i.ItemName }).ToList();
            ddlItem.DataSource = items;
            ddlItem.DataTextField = "ItemName";
            ddlItem.DataValueField = "ItemId";
            ddlItem.DataBind();
            ddlItem.Items.Insert(0, new ListItem("请选择物品", ""));
        }

        private void LoadBuyOrders()
        {
            int.TryParse(Request.QueryString["page"], out currentPage);
            if (currentPage < 1) currentPage = 1;

            var query = from b in db.BuyOrders
                        join i in db.Items on b.ItemId equals i.ItemId
                        join u in db.Users on b.UserId equals u.UserId
                        where b.Status == "Active"
                        select new
                        {
                            b.OrderId,
                            b.UserId,
                            i.ItemName,
                            b.Quantity,
                            b.Price,
                            b.CreateDate,
                            PublisherName = u.Username
                        };

            // 搜索过滤
            string keyword = txtSearch.Text.Trim();
            if (!string.IsNullOrEmpty(keyword))
                query = query.Where(x => x.ItemName.Contains(keyword));

            // 只看我的求购
            if (chkOnlyMine.Checked)
                query = query.Where(x => x.UserId == CurrentUserId);

            int totalCount = query.Count();
            int totalPages = (int)Math.Ceiling((double)totalCount / pageSize);
            if (currentPage > totalPages && totalPages > 0) currentPage = totalPages;

            var orders = query
                .OrderByDescending(x => x.CreateDate)
                .Skip((currentPage - 1) * pageSize)
                .Take(pageSize)
                .ToList();

            if (orders.Any())
            {
                rptBuyOrders.DataSource = orders;
                rptBuyOrders.DataBind();
                litNoData.Visible = false;
                BuildPagination(totalPages);
            }
            else
            {
                litNoData.Visible = true;
                rptBuyOrders.Visible = false;
                paginationDiv.Visible = false;
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
                string url = $"?page={i}";
                if (!string.IsNullOrEmpty(txtSearch.Text))
                    url += $"&search={Uri.EscapeDataString(txtSearch.Text)}";
                if (chkOnlyMine.Checked)
                    url += "&mine=1";
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
            string url = "BuyOrders.aspx?page=1";
            if (!string.IsNullOrEmpty(txtSearch.Text))
                url += $"&search={Uri.EscapeDataString(txtSearch.Text)}";
            if (chkOnlyMine.Checked)
                url += "&mine=1";
            Response.Redirect(url);
        }

        protected void chkOnlyMine_CheckedChanged(object sender, EventArgs e)
        {
            string url = "BuyOrders.aspx?page=1";
            if (!string.IsNullOrEmpty(txtSearch.Text))
                url += $"&search={Uri.EscapeDataString(txtSearch.Text)}";
            if (chkOnlyMine.Checked)
                url += "&mine=1";
            Response.Redirect(url);
        }

        protected void rptBuyOrders_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int orderId = Convert.ToInt32(e.CommandArgument);
            if (e.CommandName == "Sell")
            {
                SellToOrder(orderId);
            }
            else if (e.CommandName == "Cancel")
            {
                CancelOrder(orderId);
            }
        }

        private void SellToOrder(int orderId)
        {
            var order = db.BuyOrders.Find(orderId);
            if (order == null || order.Status != "Active")
            {
                ShowMessage("求购单已失效", true);
                return;
            }

            var sellerInv = db.Inventory.FirstOrDefault(i => i.UserId == CurrentUserId && i.ItemId == order.ItemId);
            if (sellerInv == null || sellerInv.Quantity < order.Quantity)
            {
                ShowMessage("您仓库中该物品数量不足", true);
                return;
            }

            var buyer = db.Users.Find(order.UserId);
            var seller = db.Users.Find(CurrentUserId);
            decimal totalAmount = order.Price * order.Quantity;
            if (buyer.Balance < totalAmount)
            {
                ShowMessage("买家余额不足", true);
                return;
            }

            using (var trans = db.Database.BeginTransaction())
            {
                try
                {
                    buyer.Balance -= totalAmount;
                    seller.Balance += totalAmount;
                    sellerInv.Quantity -= order.Quantity;
                    if (sellerInv.Quantity == 0)
                        db.Inventory.Remove(sellerInv);
                    var buyerInv = db.Inventory.FirstOrDefault(i => i.UserId == buyer.UserId && i.ItemId == order.ItemId);
                    if (buyerInv != null)
                        buyerInv.Quantity += order.Quantity;
                    else
                    {
                        db.Inventory.Add(new Inventory
                        {
                            UserId = buyer.UserId,
                            ItemId = order.ItemId,
                            Quantity = order.Quantity,
                            AcquireDate = DateTime.Now
                        });
                    }
                    db.Transactions.Add(new Transactions
                    {
                        UserId = buyer.UserId,
                        ItemId = order.ItemId,
                        Quantity = order.Quantity,
                        UnitPrice = order.Price,
                        TotalAmount = totalAmount,
                        TransactionDate = DateTime.Now,
                        Status = "Completed"
                    });
                    order.Status = "Filled";
                    db.SaveChanges();
                    trans.Commit();
                    Session["Balance"] = seller.Balance;
                    ShowMessage("出售成功！");
                    Response.Redirect(Request.RawUrl);
                }
                catch (Exception ex)
                {
                    trans.Rollback();
                    ShowMessage($"出售失败：{ex.Message}", true);
                }
            }
        }

        private void CancelOrder(int orderId)
        {
            var order = db.BuyOrders.Find(orderId);
            if (order == null || order.UserId != CurrentUserId || order.Status != "Active")
            {
                ShowMessage("无法取消该求购单", true);
                return;
            }
            order.Status = "Cancelled";
            db.SaveChanges();
            ShowMessage("已取消求购");
            Response.Redirect(Request.RawUrl);
        }

        protected void btnPublish_Click(object sender, EventArgs e)
        {
            // 1. 验证物品选择
            string selectedValue = ddlItem.SelectedValue;
            if (string.IsNullOrEmpty(selectedValue) || !int.TryParse(selectedValue, out int itemId) || itemId == 0)
            {
                ShowMessage("请选择物品", true);
                return;
            }

            // 2. 验证数量和价格
            if (!int.TryParse(txtQuantity.Text, out int quantity) || quantity <= 0)
            {
                ShowMessage("请输入有效的求购数量", true);
                return;
            }
            if (!decimal.TryParse(txtPrice.Text, out decimal price) || price <= 0)
            {
                ShowMessage("请输入有效的求购单价", true);
                return;
            }

            // 3. 创建求购单实体（实体类名为 BuyOrders）
            var buyOrder = new  deltatata.Models.BuyOrders
            {
                UserId = CurrentUserId,
                ItemId = itemId,
                Quantity = quantity,
                Price = price,
                Status = "Active",
                CreateDate = DateTime.Now
                // ExpireDate 可选项，不设置则为 NULL
            };
            db.BuyOrders.Add(buyOrder);
            db.SaveChanges();

            ShowMessage("求购发布成功！");
            // 重定向到当前页面，刷新列表
            Response.Redirect("BuyOrders.aspx");
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