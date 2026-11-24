<%@ Page Title="手机银行 - 塔科夫交易行" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Bank.aspx.cs" Inherits="DeltaTradeHub.Bank" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .bank-container {
            max-width: 480px;
            margin: 30px auto;
            padding: 0 16px;
            font-family: 'Segoe UI', 'Poppins', system-ui;
        }
        .card {
            background: white;
            border-radius: 32px;
            padding: 24px;
            margin-bottom: 20px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.08);
            transition: 0.2s;
        }
        .balance-card {
            background: linear-gradient(135deg, #1e2a3a, #0f172a);
            color: white;
        }
        .balance-amount {
            font-size: 36px;
            font-weight: 700;
            margin: 8px 0;
        }
        .balance-label {
            font-size: 14px;
            opacity: 0.7;
        }
        .action-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 12px;
            margin-top: 16px;
        }
        .action-btn {
            background: #ff7e00;
            border: none;
            border-radius: 60px;
            padding: 12px 0;
            color: white;
            font-weight: 600;
            cursor: pointer;
            text-align: center;
        }
        .action-btn:hover {
            background: #e66900;
            transform: translateY(-2px);
        }
        .input-group {
            margin-bottom: 16px;
        }
        .input-group label {
            display: block;
            font-size: 13px;
            margin-bottom: 6px;
            color: #334155;
        }
        .input-group input {
            width: 100%;
            padding: 12px;
            border: 1px solid #e2e8f0;
            border-radius: 20px;
            font-size: 16px;
            box-sizing: border-box;
        }
        .btn-primary {
            background: #ff7e00;
            color: white;
            border: none;
            border-radius: 40px;
            padding: 10px 20px;
            width: 100%;
            font-weight: 600;
            cursor: pointer;
        }
        .btn-outline {
            background: transparent;
            border: 1px solid #ff7e00;
            color: #ff7e00;
            border-radius: 40px;
            padding: 8px 16px;
            cursor: pointer;
        }
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            z-index: 1000;
            justify-content: center;
            align-items: center;
        }
        .modal-content {
            background: white;
            border-radius: 32px;
            width: 320px;
            padding: 24px;
            text-align: center;
        }
        .qr-code {
            width: 200px;
            height: 200px;
            margin: 16px auto;
            background: #f1f5f9;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .qr-code img {
            width: 100%;
            height: 100%;
            object-fit: contain;
        }
        .modal-footer {
            display: flex;
            gap: 12px;
            margin-top: 20px;
        }
        .toast {
            position: fixed;
            bottom: 30px;
            left: 50%;
            transform: translateX(-50%);
            background: #28a745;
            color: white;
            padding: 10px 20px;
            border-radius: 40px;
            z-index: 1100;
            display: none;
        }
        .amount-display {
            font-size: 24px;
            font-weight: 700;
            color: #ff7e00;
            margin: 10px 0;
        }
    </style>

    <div class="bank-container">
        <!-- 余额卡片 -->
        <div class="card balance-card">
            <div class="balance-label">账户余额</div>
            <div class="balance-amount">¥ <asp:Literal ID="litBalance" runat="server">0.00</asp:Literal></div>
            <div class="balance-label">可用余额</div>
        </div>

        <!-- 快捷操作 -->
        <div class="card">
            <div class="action-grid">
                <!-- ✅ 关键：所有div改为button并添加type="button" -->
                <button type="button" class="action-btn" id="btnRecharge">充值</button>
                <button type="button" class="action-btn" id="btnDeposit">存款</button>
                <button type="button" class="action-btn" id="btnWithdraw">取款</button>
            </div>
        </div>

        <!-- 存款 / 取款表单（默认隐藏） -->
        <div class="card" id="formPanel" style="display: none;">
            <h3 id="formTitle" style="margin-bottom: 16px;">存款</h3>
            <div class="input-group">
                <label>金额 (¥)</label>
                <asp:TextBox ID="txtAmount" runat="server" placeholder="输入金额" TextMode="Number" step="0.01" />
            </div>
            <asp:Button ID="btnConfirm" runat="server" Text="确认" CssClass="btn-primary" OnClick="btnConfirm_Click" />
            <div style="margin-top: 10px;">
                <!-- ✅ 关键：添加type="button" -->
                <button type="button" class="btn-outline" id="btnCancel">取消</button>
            </div>
            <asp:HiddenField ID="hdnAction" runat="server" />
        </div>
    </div>

    <!-- 第一步：输入充值金额弹窗 -->
    <div id="amountModal" class="modal">
        <div class="modal-content">
            <h3>充值金额</h3>
            <div class="input-group">
                <label>请输入充值金额（¥）</label>
                <input type="number" id="txtRechargeAmount" min="0.01" step="0.01" value="100" placeholder="输入金额">
            </div>
            <div class="modal-footer">
                <!-- ✅ 关键：添加type="button" -->
                <button type="button" class="btn-outline" id="closeAmountModal">取消</button>
                <button type="button" class="btn-primary" id="nextStep">下一步</button>
            </div>
        </div>
    </div>

    <!-- 第二步：扫码支付弹窗 -->
    <div id="rechargeModal" class="modal">
        <div class="modal-content">
            <h3>扫码支付</h3>
            <div class="amount-display">¥ <span id="displayAmount">0.00</span></div>
            <div class="qr-code">
                <img src="/img/payment-placeholder.png" alt="收款二维码（演示占位图）" onerror="this.src='/img/items/default.png'">
                <!-- 演示占位图；实际部署时把 img/payment-placeholder.png 换成自己的收款码图片，或直接修改上面的 src -->
            </div>
            <p>请使用微信/支付宝扫码支付对应金额后，点击"我已支付"</p>
            <div class="modal-footer">
                <!-- ✅ 关键：添加type="button" -->
                <button type="button" class="btn-outline" id="closeRechargeModal">取消</button>
                <button type="button" class="btn-primary" id="confirmPay">我已支付</button>
            </div>
        </div>
    </div>

    <!-- 隐藏充值提交控件 -->
    <asp:HiddenField ID="hdnRechargeAmount" runat="server" />
    <asp:Button ID="btnSubmitRecharge" runat="server" OnClick="btnSubmitRecharge_Click" style="display: none;" />

    <div class="toast" id="toastMsg"></div>

    <script src="Scripts/jquery-3.7.0.min.js"></script>
    <script>
        var currentRechargeAmount = 0;

        // 点击充值按钮，先显示金额输入弹窗
        $('#btnRecharge').click(function (e) {
            e.preventDefault(); // 阻止默认行为
            $('#txtRechargeAmount').val('100');
            $('#amountModal').css('display', 'flex');
            return false; // 彻底阻止表单提交
        });

        // 关闭金额输入弹窗
        $('#closeAmountModal').click(function (e) {
            e.preventDefault();
            $('#amountModal').css('display', 'none');
            return false;
        });

        // 点击下一步，显示二维码弹窗
        $('#nextStep').click(function (e) {
            e.preventDefault();
            var amount = parseFloat($('#txtRechargeAmount').val());
            if (isNaN(amount) || amount <= 0) {
                alert("请输入有效金额");
                return false;
            }

            currentRechargeAmount = amount;
            $('#displayAmount').text(amount.toFixed(2));
            $('#amountModal').css('display', 'none');
            $('#rechargeModal').css('display', 'flex');
            return false;
        });

        // 关闭充值弹窗
        $('#closeRechargeModal').click(function (e) {
            e.preventDefault();
            $('#rechargeModal').css('display', 'none');
            return false;
        });

        // 点击我已支付，提交充值申请
        $('#confirmPay').click(function (e) {
            e.preventDefault();
            $('#rechargeModal').css('display', 'none');

            // 提交充值申请（只有这个是真正需要提交表单的）
            $('#<%= hdnRechargeAmount.ClientID %>').val(currentRechargeAmount);
            $('#<%= btnSubmitRecharge.ClientID %>').click();
            return false;
        });

        // 存款/取款表单显示
        $('#btnDeposit').click(function (e) {
            e.preventDefault();
            $('#formTitle').text('存款');
            $('#<%= hdnAction.ClientID %>').val('deposit');
            $('#formPanel').show();
            return false;
        });

        $('#btnWithdraw').click(function (e) {
            e.preventDefault();
            $('#formTitle').text('取款');
            $('#<%= hdnAction.ClientID %>').val('withdraw');
            $('#formPanel').show();
            return false;
        });

        $('#btnCancel').click(function (e) {
            e.preventDefault();
            $('#formPanel').hide();
            $('#txtAmount').val('');
            return false;
        });

        function showToast(msg, isError) {
            var toast = $('#toastMsg');
            toast.text(msg);
            toast.css('background-color', isError ? '#dc3545' : '#28a745');
            toast.fadeIn(200);
            setTimeout(function () {
                toast.fadeOut(200);
            }, 3000);
        }
    </script>
</asp:Content>