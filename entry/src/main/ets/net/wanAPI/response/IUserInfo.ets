/**
 * 用户信息
 */
export interface IUserInfo {
  coinInfo: CoinData;
  userInfo: UserData;
}

interface CoinData {
  coinCount: number; 
  level: number; 
  nickname: string;
  rank: string; 
  userId: number; 
  username: string; 
}

interface UserData {
  admin: boolean;
  chapterTops: any[]; 
  coinCount: number; 
  collectIds: number[]; 
  email: string; 
  icon: string;
  id: number; 
  nickname: string; 
  password: string;
  publicName: string;
  token: string;
  type: number;
  username: string; 
}
