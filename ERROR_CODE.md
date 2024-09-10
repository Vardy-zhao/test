## 异常code表
| Code   | CN                              | EN                                                                                  |
|--------|---------------------------------|-------------------------------------------------------------------------------------|
|101| 缺乏必要参数或参数无效                     | Lack of necessary fields or invalid fields.                                         |
|102| 请求参数类型不对                        | bad request type                                                                    |
|103| 请求格式错误                          | bad request format                                                                  |
|201| 已有这条数据记录存在                      | bad request format.                                                                 |
|202| 数据记录不存在                         | Record is not existing.                                                             |
|205| HUBx TA 以达到上限                   | HUBx TA reach the maximum.                                                          |
|301| 账户余额不足                          | Insufficient balance of the account.                                                |
|302| 因为该交易账户余额，无法修改组别                | Can not change group as the TA has balance.                                         |
|303| 无法修改组别货币对                       | Can not update group currency.                                                      |
|305| 无法更新交易账号组别，因为该交易账号被加入MAM中       | Can not update TA Group as the trading account is used in MAM.                      |
|306| 无法出金，因为该交易账号在MAM中处于激活状态         | Can not withdraw as the trading account is active in MAM.                           |
|308| 因为该交易账号在MAM里面处于激活状态，无法修改交易账号的状态 | Can not change the status of TA as the TA is activated in MAM.                      |
|999| Core 错误                         | Core error                                                                          |
|1xxxx|                                 |                                                                                     |
|10001| 请求参数无效                          | The given data was invalid                                                          |
|10002| 操作失败                            | Operation failure                                                                   |
|10003| 文件类型不正确                         | Incorrect file type                                                                 |
|10004| 系统自定义错误                         | System customization error                                                          |
|10005| 验证码错误                           | Verification code error                                                             |
|10006| 验证码失效                           | Verification code failure                                                           |
|10007| 数据超过200时可能在批量操作过程中造成问题。         | Data over 200 may cause problems during bulk action processing.                     |
|10008| 数据发生改变，刷新页面后进行操作。               | The data has changed, please refresh the page.                                      |
|10009| 请2分钟后再提交请求。                     | Please make your new transaction after 2 minutes!                                   |
|10010| MT4 Server connection failed    | MT4服务器通讯失败                                                                          |
|10011| 缺少系统配置                          | Missing system configuration                                                        |
|10012| 已超过你的频率限制                       | You have exceeded your rate limit                                                   |
|10013| CRM系统正在维护中，请稍后再试                | CRM system is under maintenance. Please try again later                             |
|10014| 该功能暂时不可用                        | The function has been disabled temporarily                                          |
|10015| 平台名称已经存在                        | The platform name has already been taken.                                           |
|10016| CRM缺失配置项                        | CRM lacks configuration items.                                                      |
|10017| 签名验证失败                          | Signature verification failed.                                                      |
|10018| 数据库配置信息错误                       | The database information is invalid.                                                |
|10019| 官网登入链接已失效                       | The link is invalid.                                                                |
|10020| 链接已失效                           | The link has expired.                                                               |
|10021| 记录已存在                           | The same record already exists.                                                     |
|10022| 参数验证失败                          | Invalid format.                                                                     |
|10023| 填写不能为空                          | Input cannot be empty.                                                              |
|10024| 此链接已被删除，请与管理员确认                 | The link has been deleted, please check with Admin                                  |
|10025| 所选{condition}配置中包含未启用条件，请确认。    | One or more selected conditions in {condition} has been disabled                    |
|10026| 无效数据                            | Invalid payload.                                                                    |
|10027| 颁发Token无效                       | Failed to issue token.                                                              |
|20001| 通道配置文件创建失败                      | Channel configure file create failed                                                |
|20002| 当前支付方式已有同名通道                    | This payment method already has a channel of the same name.                         |
|20003| 通道配置文件删除失败                      | Channel configure file delete failed.                                               |
|20004| 通道配置文件编辑失败                      | Channel configure file edit failed.                                                 |
|20006| 当前支付方式已有同名银行码                   | This payment method already has a bank code of the same name.                       |
|20007| 指定的默认通道不存在                      | The default channel does not exist.                                                 |
|20008| 修改的金额不符合条件                      | The revised amount does not meet the requirements.                                  |
|20009| 没有可导出的内容                        | There is no exportable content.                                                     |
|20010| 不允许更改到该状态                       | Changes to this state are not allowed.                                              |
|20011| 没有设置默认问题                        | no default problem set.                                                             |
|20012| 牌照没有设置默认的交易服务器                  | jurisdiction not have trading_server.                                               |
|20013| 没有这个操作选项                        | Action error.                                                                       |
|20014| 黑名单重复                           | Duplicate blacklist.                                                                |
|20015| 缺少必填字段                          | Missing required field.                                                             |
|20016| Field 名称重复                      | Duplicate field name.                                                               |
|20017| Form Id 重复                      | Duplicate form id.                                                                  |
|20018| Default value必选填写               | Missing default value.                                                              |
|20019| Payment method 重复               | The payment method is already exist.                                                |
|20020| 通道名称已存在                         | channel name is already exist.                                                      |
|20021| 最多显示7行数据                        | display up to 7 columns                                                             |
|20022| 交易信息缺失，请检查配置                    | Data is missing, please check the funding method's configure                        |
|20023| 该通道不能被删除                        | This channel cannot be deleted                                                      |
|20024| 次序重复                            | duplicate sort.                                                                     |
|20025| 未配置卡片验证信息                       | Card validation information is not configured                                       |
|20026| Payment method 不存在              | The payment method does not exist.                                                  |
|20027| 需要一张认证卡支付                       | A certified card is required.                                                       |
|20028| 卡已通过认证，请与管理员联系进行操作。             | The card is authenticated, please contact the administrator to operate.             |
|20029| 卡号错误。                           | Card number wrong.                                                                  |
|20030| 认证卡片信息错误                        | A certified card information error.                                                 |
|20031| Affiliate Id 已经重复               | Affiliate ID {{the number}} has been assigned to another sales code {{sales code}}. |
|20032| 无效输入                            | Invalid input.                                                                      |
