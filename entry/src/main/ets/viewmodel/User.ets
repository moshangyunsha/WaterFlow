export class User {
  id: number;
  username: string;
  role: number; // 0:买家, 1:商家
  balance: number; // 余额
  token: string;   // 新增：登录凭证 (解决 RdbUtil 报错)

  // 修改构造函数，接收 5 个参数，token 设为可选或默认值
  constructor(id: number, username: string, role: number, balance: number, token: string = "") {
    this.id = id;
    this.username = username;
    this.role = role;
    this.balance = balance;
    this.token = token;
  }
}