<%@ Page Title="文章管理" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="AdminNews.aspx.cs" Inherits="DeltaTradeHub.AdminNews" %>

<asp:Content ID="Content1" ContentPlaceHolderID="PageTitle" runat="server">
    文章管理
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .search-bar {
            background: white;
            border-radius: 16px;
            padding: 16px 20px;
            margin-bottom: 20px;
            display: flex;
            gap: 12px;
            align-items: center;
            flex-wrap: wrap;
        }
        .search-bar input, .search-bar select, .search-bar button {
            padding: 8px 16px;
            border-radius: 30px;
            border: 1px solid #e2e8f0;
        }
        .search-bar button {
            background: #ff7e00;
            color: white;
            border: none;
            cursor: pointer;
        }
        .btn-add {
            background: #ff7e00;
            color: white;
            border: none;
            border-radius: 30px;
            padding: 8px 20px;
            cursor: pointer;
        }
        .news-table {
            width: 100%;
            background: white;
            border-radius: 16px;
            overflow: hidden;
            border: 1px solid #edf2f7;
        }
        .news-table th {
            background: #f8fafc;
            padding: 12px 16px;
            text-align: left;
            font-weight: 600;
            border-bottom: 1px solid #edf2f7;
        }
        .news-table td {
            padding: 12px 16px;
            border-bottom: 1px solid #edf2f7;
            vertical-align: middle;
        }
        .btn-edit, .btn-delete, .btn-top {
            border: none;
            border-radius: 20px;
            padding: 4px 12px;
            margin: 0 4px;
            cursor: pointer;
        }
        .btn-edit { background: #3b82f6; color: white; }
        .btn-delete { background: #ef4444; color: white; }
        .btn-top { background: #10b981; color: white; }
        .status-badge {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 20px;
            font-size: 12px;
            background: #dcfce7;
            color: #15803d;
        }
        .pagination {
            display: flex;
            justify-content: center;
            gap: 8px;
            margin-top: 24px;
        }
        .page-btn {
            padding: 6px 12px;
            border-radius: 30px;
            background: #f1f5f9;
            color: #64748b;
            text-decoration: none;
        }
        .page-btn.active {
            background: #ff7e00;
            color: white;
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
            border-radius: 24px;
            width: 700px;
            max-width: 90%;
            padding: 24px;
        }
        .modal-header {
            display: flex;
            justify-content: space-between;
            font-weight: 700;
            font-size: 18px;
            margin-bottom: 20px;
        }
        .form-group {
            margin-bottom: 16px;
        }
        .form-group label {
            display: block;
            font-weight: 600;
            margin-bottom: 6px;
        }
        .form-group input, .form-group select, .form-group textarea {
            width: 100%;
            padding: 8px 12px;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
        }
        .form-group textarea {
            min-height: 150px;
        }
        .modal-footer {
            display: flex;
            justify-content: flex-end;
            gap: 12px;
            margin-top: 20px;
        }
    </style>

    <div class="search-bar">
        <asp:TextBox ID="txtSearch" runat="server" placeholder="标题/作者" />
        <asp:DropDownList ID="ddlCategory" runat="server">
            <asp:ListItem Text="全部分类" Value="" />
            <asp:ListItem Text="CS2" Value="CS2" />
            <asp:ListItem Text="DOTA2" Value="DOTA2" />
        </asp:DropDownList>
        <asp:Button ID="btnSearch" runat="server" Text="搜索" OnClick="btnSearch_Click" />
        <button type="button" class="btn-add" id="btnAdd">+ 新增文章</button>
    </div>

    <asp:Repeater ID="rptNews" runat="server" OnItemCommand="rptNews_ItemCommand">
        <HeaderTemplate>
            <table class="news-table">
                <thead>
                    <tr><th>ID</th><th>标题</th><th>分类</th><th>作者</th><th>发布时间</th><th>置顶</th><th>操作</th></tr>
                </thead>
                <tbody>
        </HeaderTemplate>
        <ItemTemplate>
            <tr>
                <td><%# Eval("NewsId") %></td>
                <td><%# Eval("Title") %></td>
                <td><%# Eval("Category") %></td>
                <td><%# Eval("Author") %></td>
                <td><%# Eval("PublishDate", "{0:yyyy-MM-dd}") %></td>
                <td>
                    <asp:CheckBox ID="chkIsTop" runat="server" Checked='<%# Convert.ToBoolean(Eval("IsTop")) %>' Enabled="false" />
                 </td>
                <td>
                    <asp:Button ID="btnEdit" runat="server" CommandName="Edit" CommandArgument='<%# Eval("NewsId") %>' Text="编辑" CssClass="btn-edit" />
                    <asp:Button ID="btnToggleTop" runat="server" CommandName="ToggleTop" CommandArgument='<%# Eval("NewsId") %>' Text='<%# Convert.ToBoolean(Eval("IsTop")) ? "取消置顶" : "置顶" %>' CssClass="btn-top" />
                    <asp:Button ID="btnDelete" runat="server" CommandName="Delete" CommandArgument='<%# Eval("NewsId") %>' Text="删除" CssClass="btn-delete" OnClientClick="return confirm('确定删除吗？')" />
                 </td>
             </tr>
        </ItemTemplate>
        <FooterTemplate>
                </tbody>
            </table>
            <asp:Literal ID="litEmpty" runat="server" Visible='<%# (rptNews.Items.Count == 0) %>' Text='<div class="empty-row">暂无文章</div>' />
        </FooterTemplate>
    </asp:Repeater>

    <div class="pagination" id="paginationDiv" runat="server">
        <asp:Repeater ID="rptPagination" runat="server">
            <ItemTemplate>
                <a href='<%# Eval("Url") %>' class='page-btn <%# Eval("CssClass") %>'><%# Eval("Text") %></a>
            </ItemTemplate>
        </asp:Repeater>
    </div>

    <!-- 编辑/新增模态框 -->
    <div id="newsModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <span id="modalTitle">新增文章</span>
                <span class="close" style="cursor:pointer">&times;</span>
            </div>
            <div class="modal-body">
                <input type="hidden" id="editId" />
                <div class="form-group">
                    <label>标题</label>
                    <input type="text" id="txtTitle" class="form-control" />
                </div>
                <div class="form-group">
                    <label>分类</label>
                    <select id="ddlCat">
                        <option value="CS2">CS2</option>
                        <option value="DOTA2">DOTA2</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>作者</label>
                    <input type="text" id="txtAuthor" class="form-control" />
                </div>
                <div class="form-group">
                    <label>来源</label>
                    <input type="text" id="txtSource" class="form-control" value="BUFF" />
                </div>
                <div class="form-group">
                    <label>摘要</label>
                    <textarea id="txtSummary" rows="2"></textarea>
                </div>
                <div class="form-group">
                    <label>正文</label>
                    <textarea id="txtContent" rows="6"></textarea>
                </div>
                <div class="form-group">
                    <label>缩略图URL</label>
                    <input type="text" id="txtImageUrl" class="form-control" placeholder="/img/news/xxx.jpg" />
                </div>
                <div class="form-group">
                    <label>置顶</label>
                    <input type="checkbox" id="chkIsTop" /> 是
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn-outline" id="cancelBtn">取消</button>
                <button class="btn-primary" id="saveBtn">保存</button>
            </div>
        </div>
    </div>

    <script src="Scripts/jquery.js"></script>
    <script>
        var modal = $('#newsModal');
        var closeModal = function() { modal.css('display', 'none'); };
        $('#btnAdd').click(function() {
            $('#modalTitle').text('新增文章');
            $('#editId').val('');
            $('#txtTitle').val('');
            $('#ddlCat').val('CS2');
            $('#txtAuthor').val('');
            $('#txtSource').val('BUFF');
            $('#txtSummary').val('');
            $('#txtContent').val('');
            $('#txtImageUrl').val('');
            $('#chkIsTop').prop('checked', false);
            modal.css('display', 'flex');
        });
        $('.close, #cancelBtn').click(closeModal);
        $(window).click(function(e) { if (e.target == modal[0]) closeModal(); });

        $('#saveBtn').click(function() {
            var data = {
                id: $('#editId').val(),
                title: $('#txtTitle').val(),
                category: $('#ddlCat').val(),
                author: $('#txtAuthor').val(),
                source: $('#txtSource').val(),
                summary: $('#txtSummary').val(),
                content: $('#txtContent').val(),
                imageUrl: $('#txtImageUrl').val(),
                isTop: $('#chkIsTop').is(':checked')
            };
            $.ajax({
                url: 'AdminNews.aspx/SaveArticle',
                type: 'POST',
                contentType: 'application/json',
                data: JSON.stringify(data),
                success: function(res) {
                    alert(res.d.message);
                    if (res.d.success) location.reload();
                },
                error: function() { alert('保存失败'); }
            });
        });

        $('.btn-edit').click(function() {
            var id = $(this).closest('tr').find('td:first').text();
            $.ajax({
                url: 'AdminNews.aspx/GetArticle',
                type: 'POST',
                data: JSON.stringify({ id: id }),
                contentType: 'application/json',
                success: function(res) {
                    var art = res.d;
                    $('#modalTitle').text('编辑文章');
                    $('#editId').val(art.NewsId);
                    $('#txtTitle').val(art.Title);
                    $('#ddlCat').val(art.Category);
                    $('#txtAuthor').val(art.Author);
                    $('#txtSource').val(art.Source);
                    $('#txtSummary').val(art.Summary);
                    $('#txtContent').val(art.Content);
                    $('#txtImageUrl').val(art.ImageUrl);
                    $('#chkIsTop').prop('checked', art.IsTop);
                    modal.css('display', 'flex');
                }
            });
        });
    </script>
</asp:Content>