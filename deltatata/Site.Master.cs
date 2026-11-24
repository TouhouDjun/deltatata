using deltatata.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

namespace DeltaTradeHub
{
    public partial class SiteMaster : MasterPage
    {
        // 移除了类级别的db上下文，改为每个方法内使用using创建
        private int CurrentUserId => Session["UserId"] != null ? (int)Session["UserId"] : 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (CurrentUserId == 0) return;

            if (!IsPostBack)
            {
                LoadCartData();
                LoadUserInfo();
            }
        }

        private void LoadUserInfo()
        {
            using (var db = new DeltaTradeHubDBEntities())
            {
                var user = db.Users.Find(CurrentUserId);
                if (user != null)
                {
                    litUsername.Text = user.Username;
                    lblBalance.Text = user.Balance.ToString("N2");
                    Session["Balance"] = user.Balance;
                }
            }
        }

        private void LoadCartData()
        {
            using (var db = new DeltaTradeHubDBEntities())
            {
                var cart = (from c in db.Cart
                            join i in db.Items on c.ItemId equals i.ItemId
                            where c.UserId == CurrentUserId
                            select new { c.CartId, i.ItemName, i.Price, c.Quantity, i.Stock, i.ImageUrl }).ToList();

                if (cart.Any())
                {
                    rptCart.DataSource = cart;
                    rptCart.DataBind();
                    decimal total = cart.Sum(c => c.Price * c.Quantity);
                    var footer = (Literal)rptCart.Controls[rptCart.Controls.Count - 1].FindControl("litCartTotal");
                    if (footer != null) footer.Text = total.ToString("F2");
                    litCartEmpty.Visible = false;
                    rptCart.Visible = true;

                    var badge = (HtmlGenericControl)FindControl("cartCountBadge");
                    if (badge != null) badge.InnerText = cart.Count.ToString();
                }
                else
                {
                    litCartEmpty.Visible = true;
                    rptCart.Visible = false;
                    var badge = (HtmlGenericControl)FindControl("cartCountBadge");
                    if (badge != null) badge.InnerText = "0";
                }
            }
        }

        protected void rptCart_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandArgument == null || string.IsNullOrEmpty(e.CommandArgument.ToString()))
            {
                ShowToast("参数错误");
                return;
            }
            if (!int.TryParse(e.CommandArgument.ToString(), out int cartId))
            {
                ShowToast("参数格式错误");
                return;
            }

            using (var db = new DeltaTradeHubDBEntities())
            {
                var cartItem = db.Cart.Find(cartId);
                if (cartItem == null || cartItem.UserId != CurrentUserId) return;

                switch (e.CommandName)
                {
                    case "Remove":
                        db.Cart.Remove(cartItem);
                        break;
                    case "Minus":
                        if (cartItem.Quantity > 1) cartItem.Quantity--;
                        else return;
                        break;
                    case "Plus":
                        var item = db.Items.Find(cartItem.ItemId);
                        if (item != null && cartItem.Quantity < item.Stock)
                        {
                            cartItem.Quantity++;
                        }
                        else
                        {
                            ShowToast("已达库存上限");
                            return;
                        }
                        break;
                    default:
                        return;
                }

                db.SaveChanges();
            }

            LoadCartData();
            // 修复：使用false参数避免线程终止异常
            Response.Redirect(Request.RawUrl, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        protected void Checkout_Click(object sender, EventArgs e)
        {
            if (CurrentUserId == 0)
            {
                ShowToast("请先登录");
                return;
            }

            using (var db = new DeltaTradeHubDBEntities())
            {
                var cartItems = db.Cart.Where(c => c.UserId == CurrentUserId).ToList();
                if (cartItems.Count == 0)
                {
                    ShowToast("购物车为空");
                    return;
                }

                var user = db.Users.Find(CurrentUserId);
                if (user == null)
                {
                    ShowToast("用户不存在，请重新登录");
                    return;
                }

                // 优化：一次性加载所有商品，避免循环内重复查询
                var itemIds = cartItems.Select(c => c.ItemId).ToList();
                var itemsDict = db.Items.Where(i => itemIds.Contains(i.ItemId)).ToDictionary(i => i.ItemId);

                decimal totalCost = 0;
                // 所有前置检查在事务外完成
                foreach (var cart in cartItems)
                {
                    if (!itemsDict.TryGetValue(cart.ItemId, out var item))
                    {
                        ShowToast("商品不存在");
                        return;
                    }
                    if (item.Stock < cart.Quantity)
                    {
                        ShowToast($"商品 {item.ItemName} 库存不足");
                        return;
                    }
                    totalCost += item.Price * cart.Quantity;
                }

                if (user.Balance < totalCost)
                {
                    ShowToast("余额不足");
                    return;
                }

                // 事务开始 - 只包含必须原子执行的数据库操作
                using (var trans = db.Database.BeginTransaction())
                {
                    try
                    {
                        // 1. 扣减用户余额
                        user.Balance -= totalCost;

                        // 2. 处理每个购物车项
                        foreach (var cart in cartItems)
                        {
                            var item = itemsDict[cart.ItemId];

                            // 事务内再次检查库存（防止并发超卖）
                            if (item.Stock < cart.Quantity)
                            {
                                throw new Exception($"商品 {item.ItemName} 库存不足");
                            }

                            // 扣减库存
                            item.Stock -= cart.Quantity;

                            // 更新用户库存
                            var inv = db.Inventory.FirstOrDefault(i => i.UserId == CurrentUserId && i.ItemId == cart.ItemId);
                            if (inv != null)
                            {
                                inv.Quantity += cart.Quantity;
                            }
                            else
                            {
                                db.Inventory.Add(new Inventory
                                {
                                    UserId = CurrentUserId,
                                    ItemId = cart.ItemId,
                                    Quantity = cart.Quantity,
                                    AcquireDate = DateTime.Now
                                });
                            }

                            // 记录交易
                            db.Transactions.Add(new Transactions
                            {
                                UserId = CurrentUserId,
                                ItemId = cart.ItemId,
                                Quantity = cart.Quantity,
                                UnitPrice = item.Price,
                                TotalAmount = item.Price * cart.Quantity,
                                TransactionDate = DateTime.Now,
                                Status = "Completed"
                            });
                        }

                        // 3. 清空购物车
                        db.Cart.RemoveRange(cartItems);

                        // 4. 保存所有更改
                        db.SaveChanges();

                        // 5. 提交事务
                        trans.Commit();

                        // 事务提交成功后再执行非数据库操作
                        Session["Balance"] = user.Balance;
                        ShowToast("结算成功！");

                        // 修复：优雅重定向，不抛出线程终止异常
                        Response.Redirect(Request.RawUrl, false);
                        Context.ApplicationInstance.CompleteRequest();
                    }
                    catch (Exception ex)
                    {
                        // ✅ 这里绝对不要手动调用trans.Rollback()！
                        // using语句会在离开代码块时自动回滚未提交的事务
                        ShowToast($"结算失败：{ex.Message}");
                    }
                }
            }
        }

        /// <summary>
        /// 调用前端的 showToast 函数显示提示（不依赖 alert）
        /// </summary>
        private void ShowToast(string msg, bool isError = false)
        {
            string script = $"window.showToast('{msg.Replace("'", "\\'")}', {isError.ToString().ToLower()});";
            Page.ClientScript.RegisterStartupScript(GetType(), "toast", script, true);
        }
    }
}