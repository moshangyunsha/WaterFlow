// 文件路径: entry/src/main/ets/viewmodel/CityData.ets

export class Province {
  name: string;
  city: City[];

  constructor(name: string, city: City[]) {
    this.name = name;
    this.city = city;
  }
}

export class City {
  name: string;
  area: string[];

  constructor(name: string, area: string[]) {
    this.name = name;
    this.area = area;
  }
}

// 演示用的省市区数据
export const CITY_DATA: Province[] = [
  new Province("北京市", [
    new City("北京市", ["东城区", "西城区", "朝阳区", "海淀区", "丰台区"])
  ]),
  new Province("上海市", [
    new City("上海市", ["黄浦区", "徐汇区", "长宁区", "静安区", "浦东新区"])
  ]),
  new Province("广东省", [
    new City("广州市", ["天河区", "越秀区", "海珠区", "荔湾区", "番禺区"]),
    new City("深圳市", ["南山区", "福田区", "罗湖区", "宝安区", "龙岗区"]),
    new City("珠海市", ["香洲区", "斗门区", "金湾区"])
  ]),
  new Province("浙江省", [
    new City("杭州市", ["西湖区", "上城区", "拱墅区", "滨江区"]),
    new City("宁波市", ["海曙区", "江北区", "北仑区"])
  ]),
  new Province("江苏省", [
    new City("南京市", ["玄武区", "秦淮区", "建邺区", "鼓楼区"]),
    new City("苏州市", ["姑苏区", "吴中区", "相城区"])
  ])
];