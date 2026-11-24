using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using deltatata.Models;

namespace DeltaTradeHub
{
    public partial class MyListings : Page
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

            // 处理修改价格回发
            if (Request["__EVENTTARGET"] == "UpdatePrice")
            {
                string[] args = Request["__EVENTARGUMENT"]?.Split('|');
                if (args != null && args.Length == 2)
                {
                    if (int.TryParse(args[0], out int listingId) && decimal.TryParse(args[1], out decimal newPrice))
                    {
                        UpdateListingPrice(listingId, newPrice);
                    }
                }
                return;
            }

            if (!IsPostBack)
            {
                int.TryParse(Request.QueryString["page"], out currentPage);
                if (currentPage < 1) currentPage = 1;
                LoadListings();
            }
        }

        private void LoadListings()
        {
            // 先查询原始数据
            var rawQuery = from l in db.Listings
                           join i in db.Items on l.ItemId equals i.ItemId
                           where l.UserId == CurrentUserId
                           select new
                           {
                               l.ListingId,
                               l.ItemId,
                               i.ItemName,
                               l.Quantity,
                               l.Price,
                               l.Status,
                               l.CreateDate,
                               i.ImageUrl,
                               i.Rarity
                           };

            // 搜索
            string keyword = txtSearch.Text.Trim();
            if (!string.IsNullOrEmpty(keyword))
                rawQuery = rawQuery.Where(x => x.ItemName.Contains(keyword));

            int totalCount = rawQuery.Count();
            int totalPages = (int)Math.Ceiling((double)totalCount / pageSize);
            if (currentPage > totalPages && totalPages > 0)
                currentPage = totalPages;

            var rawData = rawQuery
                .OrderByDescending(x => x.CreateDate)
                .Skip((currentPage - 1) * pageSize)
                .Take(pageSize)
                .ToList();

            // 转换为 ViewModel
            var listings = rawData.Select(x => new ListingViewModel
            {
                ListingId = x.ListingId,
                ItemId = x.ItemId,
                ItemName = x.ItemName,
                Quantity = x.Quantity,
                Price = x.Price,
                Status = x.Status,
                CreateDate = x.CreateDate,
                ImageUrl = x.ImageUrl,
                RarityText = GetWearText(x.Rarity),
                StatusText = x.Status == "Active" ? "在售" : (x.Status == "Sold" ? "已售" : "已下架"),
                StatusClass = x.Status == "Active" ? "active" : (x.Status == "Sold" ? "sold" : "cancelled"),
                IsActive = x.Status == "Active"
            }).ToList();

            if (listings.Any())
            {
                rptListings.DataSource = listings;
                rptListings.DataBind();
                litNoData.Visible = false;
                BuildPagination(totalPages);
            }
            else
            {
                litNoData.Visible = true;
                rptListings.Visible = false;
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

        private void UpdateListingPrice(int listingId, decimal newPrice)
        {
            var listing = db.Listings.Find(listingId);
            if (listing == null || listing.UserId != CurrentUserId || listing.Status != "Active")
            {
                ShowMessage("无效的挂售单", true);
                return;
            }

            listing.Price = newPrice;
            db.SaveChanges();
            ShowMessage("价格修改成功！");
            Response.Redirect(Request.RawUrl);
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string url = "MyListings.aspx?page=1";
            if (!string.IsNullOrEmpty(txtSearch.Text))
                url += $"&search={Uri.EscapeDataString(txtSearch.Text)}";
            Response.Redirect(url);
        }

        protected void rptListings_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int listingId = Convert.ToInt32(e.CommandArgument);
            if (e.CommandName == "Cancel")
            {
                CancelListing(listingId);
            }
        }

        private void CancelListing(int listingId)
        {
            var listing = db.Listings.Find(listingId);
            if (listing == null || listing.UserId != CurrentUserId || listing.Status != "Active")
            {
                ShowMessage("无法下架", true);
                return;
            }

            // 将挂售状态改为 Cancelled，并退回库存
            listing.Status = "Cancelled";

            // 退回库存
            var inventory = db.Inventory.FirstOrDefault(i => i.UserId == CurrentUserId && i.ItemId == listing.ItemId);
            if (inventory != null)
                inventory.Quantity += listing.Quantity;
            else
            {
                db.Inventory.Add(new Inventory
                {
                    UserId = CurrentUserId,
                    ItemId = listing.ItemId,
                    Quantity = listing.Quantity,
                    AcquireDate = DateTime.Now
                });
            }

            db.SaveChanges();
            ShowMessage("已下架，物品已退回库存");
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

        public class ListingViewModel
        {
            public int ListingId { get; set; }
            public int ItemId { get; set; }
            public string ItemName { get; set; }
            public int Quantity { get; set; }
            public decimal Price { get; set; }
            public string Status { get; set; }
            public DateTime CreateDate { get; set; }
            public string ImageUrl { get; set; }
            public string RarityText { get; set; }
            public string StatusText { get; set; }
            public string StatusClass { get; set; }
            public bool IsActive { get; set; }
        }

        public class PageLink
        {
            public string Text { get; set; }
            public string Url { get; set; }
            public string CssClass { get; set; }
        }
    }
}