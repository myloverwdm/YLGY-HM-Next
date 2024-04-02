import HashMap from '@ohos.util.HashMap';
import ArrayList from '@ohos.util.ArrayList';

@Entry
@Component
struct Index {
  // 卡片的个数
  @State cardCount: number = 100
  // 卡片的高度，需要是偶数
  static cardHeight: number = 50
  // 卡片的宽度，需要是偶数
  static cardWidth: number = 40

  // 当前游戏的状态，初始化、游戏中、失败、成功
  @State state: string = "INIT"

  // 当前点击的id
  @State @Watch('clickIdChange') nowClickId: number = -1
  @State cardInfoList: Array<CardInfo> = new Array()
  @State xCoordinateList: Array<number> = new Array()
  @State yCoordinateList: Array<number> = new Array()
  // 每个卡片是否能点击
  @State canChooseList: Array<boolean> = new Array()
  // 是否删除
  @State deletedList: Array<boolean> = new Array()
  // 为了先改变下面的图片，再删除。 而改变图片需要依赖于删除操作。故增加copy
  @State deletedListCopy: Array<boolean> = new Array()
  // 卡槽的卡片
  @State clickArray: Array<number> = new Array(-1, -1, -1, -1, -1, -1, -1)
  // 当是否在被点击，防止点击过快，导致上一次还未处理完毕，下一次就开始了
  @State nowOnClick: boolean = false
  // 当前被点击的卡片数量
  @State nowClickCount: number = 0

  onPageShow() {

  }

  initCard() {
    this.state = "RUNNING"
    this.index = 0
    this.nowClickCount = 0
    this.clickArray = new Array(-1, -1, -1, -1, -1, -1, -1)
    this.cardInfoList = new Array()
    this.xCoordinateList = new Array()
    this.yCoordinateList = new Array()
    this.canChooseList = new Array()
    this.deletedList = new Array()
    this.deletedListCopy = new Array()
    // 需要是3的倍数
    this.cardCount = Math.max(3, this.cardCount - (this.cardCount % 3))
    for (let i = 0; i < this.cardCount; i++) {
      this.buildOneCard(-1, -1, i)
    }
  }

  build() {
    Column() {
      if (this.state != "RUNNING") {
        // 弹窗
        Column() {
          Row() {
            Text("卡片数量")
              .width("50%")
              .height("20%")
              .fontSize("20fp")
              .fontColor('#000000')
            TextInput({ text: this.cardCount + "" })
              .width("50%")
              .height("20%")
              .type(InputType.Number)
              .maxLength(4)
              .onChange((value: string) => {
                if (value.length > 0) {
                  this.cardCount = Number.parseInt(value)
                }
              })
          }

          Button(this.state == "INIT" ? '开始游戏' : "重新开始", { type: ButtonType.Normal, stateEffect: true })
            .borderRadius(8)
            .backgroundColor(0x317aff)
            .width(90)
            .onClick(() => {
              this.initCard()
            })
        }
        .width("60%")
        .height("40%")
        .alignItems(HorizontalAlign.Center)
        .backgroundColor("#ddf3f2")

      } else {
        // 卡片
        Stack({}) {
          ForEach(this.cardInfoList, (card, index) => {
            if (!this.deletedList[index]) {
              // 没有删除则显示
              CardComponent({
                centerX: this.xCoordinateList[index],
                centerY: this.yCoordinateList[index],
                index: card.imageIndex,
                compId: card.index,
                canChoose: this.canChooseList[index],
                // 父子双向
                nowClickId: $nowClickId
              })
            }

          })
        }.width('100%').height(150).margin({ top: 50 })

        // 卡槽
        Row() {
          // 由于foreach中会合并相同key的数据，所以使用多个if，而不是foreach
          if (this.clickArray[0] != -1) {
            Image(Index.cardImageArray[this.clickArray[0]])
              .width(Index.cardWidth)
              .height(Index.cardHeight)
          }
          if (this.clickArray[1] != -1) {
            Image(Index.cardImageArray[this.clickArray[1]])
              .width(Index.cardWidth)
              .height(Index.cardHeight)
          }
          if (this.clickArray[2] != -1) {
            Image(Index.cardImageArray[this.clickArray[2]])
              .width(Index.cardWidth)
              .height(Index.cardHeight)
          }
          if (this.clickArray[3] != -1) {
            Image(Index.cardImageArray[this.clickArray[3]])
              .width(Index.cardWidth)
              .height(Index.cardHeight)
          }
          if (this.clickArray[4] != -1) {
            Image(Index.cardImageArray[this.clickArray[4]])
              .width(Index.cardWidth)
              .height(Index.cardHeight)
          }
          if (this.clickArray[5] != -1) {
            Image(Index.cardImageArray[this.clickArray[5]])
              .width(Index.cardWidth)
              .height(Index.cardHeight)
          }
          if (this.clickArray[6] != -1) {
            Image(Index.cardImageArray[this.clickArray[6]])
              .width(Index.cardWidth)
              .height(Index.cardHeight)
          }
        }
        .position({ x: Index.cardWidth * 1.5, y: Index.cardHeight * 13 })
        .width(Index.cardWidth * 7 + 10)
        .height(Index.cardHeight)
        .alignItems(VerticalAlign.Top)
        .backgroundColor('#ff236707')
      }

    }
    .backgroundImage($r('app.media.beijing'))
    .backgroundImageSize({ width: "100%", height: "100%" })
    .height('100%')
    .width('100%')
  }

  @State index: number = 0

  buildOneCard(x: number, y: number, nowIndex: number) {
    let card = new CardInfo()
    if (x != -1 && y != -1) {
      // 用于做指定的测试
      card.x = x;
      card.y = y;
    } else {
      card.x = Math.floor(Math.random() * 10) * Index.cardWidth / 2 + 100
      card.y = Math.floor(Math.random() * 18) * Index.cardHeight / 2 + 30
    }
    card.index = this.index
    card.imageIndex = this.getRandomImageIndex(nowIndex)
    this.cardInfoList[this.index] = card
    this.deletedList.push(false)
    this.deletedListCopy.push(false)
    this.xCoordinateList.push(card.x)
    this.yCoordinateList.push(card.y)
    this.canChooseList.push(true)

    this.cardInOtherCard(card)

    this.index++
  }

  /**
   * 将一个card下的所有卡片置为被覆盖
   */
  cardInOtherCard(card: CardInfo) {
    for (let i = 0; i < card.index; i++) {
      if (!this.deletedList[i] && this.twoCardsIntersecting(this.cardInfoList[i], card)) {
        this.canChooseList[i] = false
      }
    }
  }

  /**
   * 判断卡片是否相交
   */
  twoCardsIntersecting(card1: CardInfo, card2: CardInfo) {
    let x1 = card1.x
    let x2 = card1.x + Index.cardWidth
    let x3 = card2.x
    let x4 = card2.x + Index.cardWidth

    let y1 = card1.y
    let y2 = card1.y + Index.cardHeight
    let y3 = card2.y
    let y4 = card2.y + Index.cardHeight

    if (x2 <= x3 || x4 <= x1) {
      return false;
    }
    // 判断两个长方形在 y 轴上是否有重叠
    if (y2 <= y3 || y4 <= y1) {
      return false;
    }
    // 两个长方形在 x 轴和 y 轴上都有重叠，相交
    return true;
  }


  /**
   * 将一个card下的所有卡片置为未被覆盖
   */
  cardCanChoose(card: CardInfo) {
    for (let i = 0; i < card.index; i++) {
      // 和此卡片相交， 且此卡片没有被其它覆盖的
      if (!this.deletedListCopy[i] && this.twoCardsIntersecting(this.cardInfoList[i], card)) {
        if (!this.haveCardOnThis(this.cardInfoList[i])) {
          this.canChooseList[i] = true
        }
      }
    }
  }

  /**
   * 判断某个卡片是否是被其它覆盖的,所以取的是index大于当前的
   */
  haveCardOnThis(card: CardInfo) {
    for (let i = card.index + 1; i < this.cardInfoList.length; i++) {
      let aboveCard = this.cardInfoList[i]
      if (!this.deletedListCopy[i] && this.twoCardsIntersecting(aboveCard, card)) {
        return true
      }
    }
    return false
  }

  lastImageIndex: number = 0

  getRandomImageIndex(nowIndex: number) {
    if (nowIndex % 3 == 0) {
      // 每三个都是一样的，这样能保证一定是有解的
      this.lastImageIndex = Math.round(Math.random() * Math.max(Index.cardImageArray.length - 1, 1))
    }
    return this.lastImageIndex
  }

  clickIdChange(ignore: string) {
    if (this.nowOnClick) {
      return
    }
    this.nowClickCount++
    this.nowOnClick = true
    let card = this.cardInfoList[this.nowClickId]
    if (this.canChooseList[card.index]) {
      this.deletedListCopy[card.index] = true
      this.cardCanChoose(card)
      // 更新clickArray
      this.updateClickArray(card.imageIndex)
      // 判断是不是已经满了
      if (this.clickArray[this.clickArray.length -1] != -1) {
        this.state = "FAILED"
      }
      this.deletedList[card.index] = true
    }
    this.nowOnClick = false
    // 判断是不是已经点击完毕了
    if (this.nowClickCount == this.cardCount) {
      this.state = "SUCCESS"
    }
  }

  updateClickArray(imageIndex: number) {
    for (let i = 0; i < this.clickArray.length; i++) {
      if (this.clickArray[i] == -1) {
        this.clickArray[i] = imageIndex
        break
      }
    }
    let nowCount = 0
    let newArray = new Array()
    for (let i = 0; i < this.clickArray.length; i++) {
      if (this.clickArray[i] == imageIndex) {
        nowCount++
      } else {
        newArray.push(this.clickArray[i])
      }
    }
    // 不需要去除重复的
    if (nowCount < 3) {
      return
    }
    // 去除重复的
    for (let i = 0; i < newArray.length; i++) {
      this.clickArray[i] = newArray[i]
    }
    for (let i = newArray.length; i < this.clickArray.length; i++) {
      this.clickArray[i] = -1;
    }
  }

  // 可点击的卡片列表
  public static cardImageArray: Array<Resource> = new Array(
    $r('app.media.0'),
    $r('app.media.1'),
    $r('app.media.2'),
    $r('app.media.3'),
    $r('app.media.4'),
    $r('app.media.5'),
    $r('app.media.6'),
    $r('app.media.7'),
    $r('app.media.8')
  );
  // 不可点击的卡片列表
  public static cardImageArray2: Array<Resource> = new Array(
    $r('app.media.00'),
    $r('app.media.11'),
    $r('app.media.22'),
    $r('app.media.33'),
    $r('app.media.44'),
    $r('app.media.55'),
    $r('app.media.66'),
    $r('app.media.77'),
    $r('app.media.88')
  );
}

/**
 * 自定义卡片组件
 */
@Component
struct CardComponent {
  @Prop centerX: number;
  @State centerY: number = 0;
  oldCenterX: number = 0;
  oldCenterY: number = 0;
  @State index: number = 1;
  @Prop canChoose: boolean;
  compId: number = 0;
  @Link nowClickId: number

  build() {
    Image(this.canChoose ? Index.cardImageArray[this.index] : Index.cardImageArray2[this.index])
      .width(Index.cardWidth)
      .height(Index.cardHeight)
      .position({ x: this.centerX, y: this.centerY })
      .onClick(() => {
        if (this.canChoose) {
          this.nowClickId = this.compId
        }
      })
  }
}

class CardInfo {
  x: number
  y: number
  imageIndex: number
  index: number
}
