using System;
using System.Web.UI;
using deltatata.Models;

namespace DeltaTradeHub
{
    public partial class Bank : Page
    {
        private int CurrentUserId => Session["UserId"] != null ? (int)Session["UserId"] : 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (CurrentUserId == 0)
            {
                Response.Redirect("Auth.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!IsPostBack)
            {
                LoadBalance();
            }
        }

        private void LoadBalance()
        {
            using (var db = new DeltaTradeHubDBEntities())
            {
                var user = db.Users.Find(CurrentUserId);
                if (user != null)
                {
                    litBalance.Text = user.Balance.ToString("N2");
                    Session["Balance"] = user.Balance;
                }
            }
        }

        // 专门处理充值申请的按钮点击事件
        protected void btnSubmitRecharge_Click(object sender, EventArgs e)
        {
            string amountStr = hdnRechargeAmount.Value;
            if (decimal.TryParse(amountStr, out decimal amount) && amount > 0)
            {
                CreateRechargeOrder(amount);
            }
            else
            {
                ShowMessage("充值金额无效，请输入大于0的数字", true);
            }
        }

        // 修复后的创建充值订单方法（主键改为Id）
        private void CreateRechargeOrder(decimal amount)
        {
            try
            {
                using (var db = new DeltaTradeHubDBEntities())
                {
                    var order = new RechargeOrders
                    {
                        UserId = CurrentUserId,
                        Amount = amount,
                        Status = "Pending",
                        CreateTime = DateTime.Now,
                        Remark = "用户扫码充值"
                    };

                    db.RechargeOrders.Add(order);
                    int affectedRows = db.SaveChanges();

                    if (affectedRows > 0)
                    {
                        // 主键是Id不是OrderId
                        ShowMessage($"充值申请提交成功！订单号：{order.Id}，金额 ¥{amount:N2}，请等待管理员审核。");
                    }
                    else
                    {
                        ShowMessage("充值申请提交失败：数据库未记录任何更改", true);
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage($"充值申请提交失败：{ex.Message}", true);
            }

            Response.Redirect(Request.RawUrl, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        // 存款（直接到账，测试用）
        private void PerformDeposit(decimal amount)
        {
            using (var db = new DeltaTradeHubDBEntities())
            {
                var user = db.Users.Find(CurrentUserId);
                if (user == null) return;

                user.Balance += amount;
                db.SaveChanges();
                Session["Balance"] = user.Balance;
            }

            ShowMessage($"存款成功！增加 ¥{amount:N2}");
            Response.Redirect(Request.RawUrl, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        // 取款（直接扣除）
        private void PerformWithdraw(decimal amount)
        {
            using (var db = new DeltaTradeHubDBEntities())
            {
                var user = db.Users.Find(CurrentUserId);
                if (user == null) return;

                if (user.Balance < amount)
                {
                    ShowMessage("余额不足", true);
                    return;
                }

                user.Balance -= amount;
                db.SaveChanges();
                Session["Balance"] = user.Balance;
            }

            ShowMessage($"取款成功！减少 ¥{amount:N2}");
            Response.Redirect(Request.RawUrl, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        protected void btnConfirm_Click(object sender, EventArgs e)
        {
            if (!decimal.TryParse(txtAmount.Text, out decimal amount) || amount <= 0)
            {
                ShowMessage("请输入有效金额", true);
                return;
            }

            string action = hdnAction.Value;
            if (action == "deposit")
                PerformDeposit(amount);
            else if (action == "withdraw")
                PerformWithdraw(amount);
            else
                ShowMessage("操作类型无效", true);
        }

        private void ShowMessage(string msg, bool isError = false)
        {
            string script = $"showToast('{msg.Replace("'", "\\'")}', {isError.ToString().ToLower()});";
            ClientScript.RegisterStartupScript(GetType(), "toast", script, true);
        }
    }
}