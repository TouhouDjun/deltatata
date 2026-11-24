using deltatata.Models;
using System;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DeltaTradeHub
{
    public partial class UserCenter : Page
    {
        private DeltaTradeHubDBEntities db = new DeltaTradeHubDBEntities();
        private int CurrentUserId => Session["UserId"] != null ? (int)Session["UserId"] : 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (CurrentUserId == 0)
            {
                Response.Redirect("Auth.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadUserData();
            }
        }

        private void LoadUserData()
        {
            var user = db.Users.Find(CurrentUserId);
            if (user == null) return;

            // 侧边栏信息
            litAvatarChar.Text = user.Username.Substring(0, 1).ToUpper();
            litUsername.Text = user.Username;
            litBalance.Text = user.Balance.ToString("N2");

            // 个人信息面板
            txtUsername.Text = user.Username;
            txtEmail.Text = user.Email;
            txtRegisterDate.Text = user.RegisterDate.ToString("yyyy-MM-dd HH:mm:ss");

            // 统计数据
            int boughtCount = db.Transactions.Count(t => t.UserId == CurrentUserId && t.Status == "Completed");
            // 在售物品数量（从 Listings 表，如果没有则显示 0）
            int sellingCount = 0;
            try { sellingCount = db.Listings.Count(l => l.UserId == CurrentUserId && l.Status == "Active"); } catch { }
            litBoughtCount.Text = boughtCount.ToString();
            litSellingCount.Text = sellingCount.ToString();
            litPendingOrders.Text = "0"; // 待处理订单后续可扩展

            // 我的订单
            var orders = (from t in db.Transactions
                          join i in db.Items on t.ItemId equals i.ItemId
                          where t.UserId == CurrentUserId
                          orderby t.TransactionDate descending
                          select new { t.TransactionDate, i.ItemName, t.Quantity, t.UnitPrice, t.TotalAmount, t.Status }).Take(20).ToList();
            if (orders.Any())
            {
                rptOrders.DataSource = orders;
                rptOrders.DataBind();
            }
            else
            {
                litEmptyOrders.Visible = true;
            }

            // 我的饰品（仓库物品）
            var inventory = (from inv in db.Inventory
                             join it in db.Items on inv.ItemId equals it.ItemId
                             where inv.UserId == CurrentUserId && inv.Quantity > 0
                             select new { it.ItemName, inv.Quantity, it.Price, it.Rarity }).ToList();
            if (inventory.Any())
            {
                rptInventory.DataSource = inventory;
                rptInventory.DataBind();
            }
            else
            {
                litEmptyInventory.Visible = true;
            }

            // 求购记录
            var buyOrders = (from b in db.BuyOrders
                             join i in db.Items on b.ItemId equals i.ItemId
                             where b.UserId == CurrentUserId
                             orderby b.CreateDate descending
                             select new { i.ItemName, b.Quantity, b.Price, b.Status, b.CreateDate }).Take(20).ToList();
            if (buyOrders.Any())
            {
                rptBuyOrders.DataSource = buyOrders;
                rptBuyOrders.DataBind();
            }
            else
            {
                litEmptyBuyOrders.Visible = true;
            }

            // 账户安全
            txtSecurityEmail.Text = user.Email;

            // 更新母版页余额
            MasterPage master = this.Master;
            Label lblMasterBalance = master?.FindControl("lblBalance") as Label;
            if (lblMasterBalance != null) lblMasterBalance.Text = user.Balance.ToString("N2");
        }

        protected void btnEditProfile_Click(object sender, EventArgs e)
        {
            // 跳转到修改资料页面，暂用提示
            ClientScript.RegisterStartupScript(this.GetType(), "edit", "alert('修改信息功能开发中，后续可跳转到修改页面');", true);
        }

        protected void btnChangePwd_Click(object sender, EventArgs e)
        {
            ClientScript.RegisterStartupScript(this.GetType(), "pwd", "alert('密码修改功能开发中，后续跳转到修改密码页面');", true);
        }

        protected void btnBindPhone_Click(object sender, EventArgs e)
        {
            ClientScript.RegisterStartupScript(this.GetType(), "phone", "alert('绑定手机功能开发中');", true);
        }
    }
}