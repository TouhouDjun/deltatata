using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using deltatata.Models;

namespace DeltaTradeHub
{
    public partial class Storehouse : Page
    {
        private DeltaTradeHubDBEntities db = new DeltaTradeHubDBEntities();
        private int CurrentUserId => Session["UserId"] != null ? (int)Session["UserId"] : 0;
        private int pageSize = 12;
        private int currentPage = 1;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (CurrentUserId == 0)
            {
                Response.Redirect("Auth.aspx");
                return;
            }

            // 处理出售回发
            if (Request["__EVENTTARGET"] == "SellItem")
            {
                string[] args = Request["__EVENTARGUMENT"]?.Split('|');
                if (args != null && args.Length == 3)
                {
                    if (int.TryParse(args[0], out int inventoryId) &&
                        decimal.TryParse(args[1], out decimal price) &&
                        int.TryParse(args[2], out int quantity))
                    {
                        SellInventoryItem(inventoryId, price, quantity);
                    }
                }
                return;
            }

            if (!IsPostBack)
            {
                int.TryParse(Request.QueryString["page"], out currentPage);
                if (currentPage < 1) currentPage = 1;
                LoadInventory();
            }
        }

        private void LoadInventory()
        {
            // 先查询原始数据（不包含 GetWearText 转换）
            var rawQuery = from inv in db.Inventory
                           join it in db.Items on inv.ItemId equals it.ItemId
                           where inv.UserId == CurrentUserId && inv.Quantity > 0
                           select new
                           {
                               inv.InventoryId,
                               it.ItemId,
                               it.ItemName,
                               it.Price,
                               inv.Quantity,
                               inv.AcquireDate,
                               it.ImageUrl,
                               it.Rarity,
                               it.CategoryId
                           };

            // 搜索
            string keyword = txtSearch.Text.Trim();
            if (!string.IsNullOrEmpty(keyword))
                rawQuery = rawQuery.Where(x => x.ItemName.Contains(keyword));

            int totalCount = rawQuery.Count();
            int totalPages = (int)Math.Ceiling((double)totalCount / pageSize);
            if (currentPage > totalPages && totalPages > 0)
                currentPage = totalPages;

            // 获取当前页数据
            var rawData = rawQuery
                .OrderByDescending(x => x.AcquireDate)
                .Skip((currentPage - 1) * pageSize)
                .Take(pageSize)
                .ToList();

            // 在内存中转换为 ViewModel，调用 GetWearText
            var inventory = rawData.Select(x => new InventoryViewModel
            {
                InventoryId = x.InventoryId,
                ItemId = x.ItemId,
                ItemName = x.ItemName,
                Price = x.Price,
                Quantity = x.Quantity,
                AcquireDate = x.AcquireDate,
                ImageUrl = x.ImageUrl,
                RarityText = GetWearText(x.Rarity),
                IsUsable = x.CategoryId == 4 // 医疗品类目ID为4
            }).ToList();

            if (inventory.Any())
            {
                rptInventory.DataSource = inventory;
                rptInventory.DataBind();
                litNoData.Visible = false;
                BuildPagination(totalPages);
            }
            else
            {
                litNoData.Visible = true;
                rptInventory.Visible = false;
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

        private void SellInventoryItem(int inventoryId, decimal price, int quantity)
        {
            var inventory = db.Inventory.Find(inventoryId);
            if (inventory == null || inventory.UserId != CurrentUserId || inventory.Quantity < quantity)
            {
                ShowMessage("库存不足或操作无效", true);
                return;
            }

            // 创建挂售记录
            var listing = new Listings
            {
                UserId = CurrentUserId,
                ItemId = inventory.ItemId,
                Quantity = quantity,
                Price = price,
                Status = "Active",
                CreateDate = DateTime.Now
            };
            db.Listings.Add(listing);

            // 更新库存
            inventory.Quantity -= quantity;
            if (inventory.Quantity == 0)
                db.Inventory.Remove(inventory);

            db.SaveChanges();
            ShowMessage("上架成功！");
            Response.Redirect(Request.RawUrl);
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string url = "Storehouse.aspx?page=1";
            if (!string.IsNullOrEmpty(txtSearch.Text))
                url += $"&search={Uri.EscapeDataString(txtSearch.Text)}";
            Response.Redirect(url);
        }

        protected void rptInventory_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int inventoryId = Convert.ToInt32(e.CommandArgument);
            if (e.CommandName == "Use")
            {
                UseInventoryItem(inventoryId);
            }
        }

        private void UseInventoryItem(int inventoryId)
        {
            var inventory = db.Inventory.Find(inventoryId);
            if (inventory == null || inventory.UserId != CurrentUserId || inventory.Quantity < 1)
            {
                ShowMessage("无法使用", true);
                return;
            }

            inventory.Quantity -= 1;
            if (inventory.Quantity == 0)
                db.Inventory.Remove(inventory);
            db.SaveChanges();

            ShowMessage("使用成功！");
            Response.Redirect(Request.RawUrl);
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

        private void ShowMessage(string msg, bool isError = false)
        {
            string script = $"alert('{(isError ? "❌ " : "✅ ")}{msg.Replace("'", "\\'")}');";
            ClientScript.RegisterStartupScript(GetType(), "toast", script, true);
        }

        public class InventoryViewModel
        {
            public int InventoryId { get; set; }
            public int ItemId { get; set; }
            public string ItemName { get; set; }
            public decimal Price { get; set; }
            public int Quantity { get; set; }
            public DateTime AcquireDate { get; set; }
            public string ImageUrl { get; set; }
            public string RarityText { get; set; }
            public bool IsUsable { get; set; }
        }

        public class PageLink
        {
            public string Text { get; set; }
            public string Url { get; set; }
            public string CssClass { get; set; }
        }
    }
}