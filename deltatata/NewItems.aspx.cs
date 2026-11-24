using deltatata.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DeltaTradeHub
{
    public partial class NewItems : System.Web.UI.Page
    {
        // 数据库上下文（和你的Market.aspx.cs保持一致）
        private DeltaTradeHubDBEntities db = new DeltaTradeHubDBEntities();

        // 分页模型
        public class PaginationModel
        {
            public string Url { get; set; }
            public string CssClass { get; set; }
            public string Text { get; set; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindNewItems(); // 绑定最新上架饰品
                BindPagination(); // 绑定分页
            }
        }

        /// <summary>
        /// 绑定最新上架饰品（核心：按CreateDate倒序）
        /// </summary>
        private void BindNewItems()
        {
            try
            {
                // 只查CS2饰品，按创建时间倒序
                var newItems = db.Items
                                 .Where(i => i.IsAvailable == true && i.CategoryId == 1)
                                 .OrderByDescending(i => i.CreateDate)
                                 .Select(i => new
                                 {
                                     i.ItemId,
                                     i.ItemName,
                                     i.Price,
                                     i.Rarity,
                                     i.Stock,
                                     i.ImageUrl,
                                     i.CreateDate
                                 }).ToList();

                if (newItems.Count == 0)
                {
                    litNoData.Visible = true;
                    rptNewItems.Visible = false;
                }
                else
                {
                    litNoData.Visible = false;
                    rptNewItems.Visible = true;
                    rptNewItems.DataSource = newItems;
                    rptNewItems.DataBind();
                }
            }
            catch (Exception ex)
            {
                litNoData.Visible = true;
                litNoData.Text = $"<div class='no-data'>加载失败：{ex.Message}</div>";
            }
        }

        /// <summary>
        /// 绑定分页（和Market.aspx分页逻辑一致）
        /// </summary>
        private void BindPagination()
        {
            List<PaginationModel> paginationList = new List<PaginationModel>();
            int totalCount = db.Items.Count(i => i.IsAvailable == true && i.CategoryId == 1);
            int pageSize = 8;
            int totalPages = (int)Math.Ceiling((double)totalCount / pageSize);
            int currentPage = 1;

            if (!string.IsNullOrEmpty(Request.QueryString["page"]))
            {
                int.TryParse(Request.QueryString["page"], out currentPage);
                currentPage = currentPage < 1 ? 1 : currentPage;
                currentPage = currentPage > totalPages ? totalPages : currentPage;
            }

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

        /// <summary>
        /// 磨损度短文本（标签显示）
        /// </summary>
        public string GetWearText(string rarity)
        {
            switch (rarity?.ToLower())
            {
                case "factory_new": return "崭新";
                case "minimal_wear": return "略磨";
                case "field_tested": return "久经";
                case "well_worn": return "破损";
                case "battle_scarred": return "战痕";
                default: return "普通";
            }
        }

        /// <summary>
        /// 磨损度完整描述
        /// </summary>
        public string GetWearDesc(string rarity)
        {
            switch (rarity?.ToLower())
            {
                case "factory_new": return "崭新出厂";
                case "minimal_wear": return "略有磨损";
                case "field_tested": return "久经沙场";
                case "well_worn": return "破损不堪";
                case "battle_scarred": return "战痕累累";
                default: return "普通品质";
            }
        }

        /// <summary>
        /// 立即购买接口（和Market.aspx一致）
        /// </summary>
        [WebMethod]
        public static object DirectPurchase(int itemId)
        {
            int userId = 1; // 替换为你的Session["UserId"]
            using (var db = new DeltaTradeHubDBEntities())
            {
                using (var tran = db.Database.BeginTransaction())
                {
                    try
                    {
                        var item = db.Items.FirstOrDefault(i => i.ItemId == itemId && i.IsAvailable == true);
                        if (item == null || item.Stock <= 0)
                        {
                            tran.Rollback();
                            return new { success = false, message = item == null ? "饰品不存在" : "已售罄" };
                        }

                        // 扣库存
                        item.Stock -= 1;
                        db.Entry(item).State = System.Data.Entity.EntityState.Modified;

                        // 新增交易记录
                        var trans = new Transactions
                        {
                            UserId = userId,
                            ItemId = itemId,
                            Quantity = 1,
                            UnitPrice = item.Price,
                            TotalAmount = item.Price,
                            TransactionDate = DateTime.Now,
                            Status = "Completed"
                        };
                        db.Transactions.Add(trans);

                        // 扣余额
                        var user = db.Users.FirstOrDefault(u => u.UserId == userId);
                        if (user == null || user.Balance < item.Price)
                        {
                            tran.Rollback();
                            return new { success = false, message = user == null ? "用户不存在" : "余额不足" };
                        }
                        user.Balance -= item.Price;
                        db.Entry(user).State = System.Data.Entity.EntityState.Modified;

                        db.SaveChanges();
                        tran.Commit();
                        return new { success = true, message = "购买成功" };
                    }
                    catch (Exception ex)
                    {
                        tran.Rollback();
                        return new { success = false, message = $"购买失败：{ex.Message}" };
                    }
                }
            }
        }

        /// <summary>
        /// 加入购物车接口（和Market.aspx一致）
        /// </summary>
        [WebMethod]
        public static object AddCart(int itemId)
        {
            int userId = 1; // 替换为你的Session["UserId"]
            using (var db = new DeltaTradeHubDBEntities())
            {
                try
                {
                    var item = db.Items.FirstOrDefault(i => i.ItemId == itemId && i.IsAvailable == true);
                    if (item == null || item.Stock <= 0)
                    {
                        return new { success = false, message = item == null ? "饰品不存在" : "已售罄" };
                    }

                    // 检查购物车是否已有该商品
                    var cartItem = db.Cart.FirstOrDefault(c => c.UserId == userId && c.ItemId == itemId);
                    if (cartItem != null)
                    {
                        cartItem.Quantity += 1;
                        db.Entry(cartItem).State = System.Data.Entity.EntityState.Modified;
                    }
                    else
                    {
                        cartItem = new Cart
                        {
                            UserId = userId,
                            ItemId = itemId,
                            Quantity = 1,
                            AddDate = DateTime.Now
                        };
                        db.Cart.Add(cartItem);
                    }

                    db.SaveChanges();
                    return new { success = true, message = "加入购物车成功" };
                }
                catch (Exception ex)
                {
                    return new { success = false, message = $"加入购物车失败：{ex.Message}" };
                }
            }
        }
    }
}