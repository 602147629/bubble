package  
{
import data.BubbleVo;
import event.BubbleEvent;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.utils.Dictionary;
import flash.utils.getTimer;
import utils.MathUtil;
import utils.Random;
/**
 * ...泡泡龙测试
 * @author Kanon
 */
public class BubbleTest extends Sprite 
{
    private var bubble:Bubble;
    private var cannon:Cannon;
    private var aimMc:Sprite;
    private var radius:Number = 30;
    private var color:uint;
    private var colorType:int = 5;
    private var cMc:MovieClip;
    private var colorAry:Array = [null, 0xFF00FF, 0xFFFF00, 0x0000FF, 0xCCFF00, 0x00CCFF];
	private var fallList:Dictionary;
    public function BubbleTest() 
    {
        this.init();
        this.initUI();
        this.addEventListener(Event.ENTER_FRAME, loop);
        stage.addEventListener(MouseEvent.CLICK, mouseClickHander);
        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownHandler);
    }
	
	private function onKeyDownHandler(event:KeyboardEvent):void 
	{
		var arr:Array = this.bubble.addLine([Random.randint(1, this.colorType), Random.randint(1, this.colorType), 3, 4, 5, 5]);
		this.drawLineBubble(arr);
	}
    
    /**
     * 初始化
     */
    private function init():void 
    {
        stage.align = StageAlign.TOP_LEFT;
		this.fallList = new Dictionary();
        this.bubble = new Bubble(6, this.radius);
        this.bubble.addEventListener(BubbleEvent.UPDATE, updateHandler);
        this.bubble.addEventListener(BubbleEvent.REMOVE_BUBBLE, removeBubbleHandler);
        this.bubble.range = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
        this.cannon = new Cannon(stage.stageWidth * .5, stage.stageHeight, 20);
        this.color = Random.randint(1, this.colorType);
		for (var i:int = 0; i < 5; i++) 
		{
			this.bubble.addLine([Random.randint(1, this.colorType), Random.randint(1, this.colorType), 3, 4, 5, 5])
		}
		this.drawLineBubble(this.bubble.getBubbleList());
	}
    
    /**
     * 初始化UI
     */
    private function initUI():void
    {
        this.aimMc = new AimMc();
        this.aimMc.x = this.cannon.startX;
        this.aimMc.y = this.cannon.startY;
        this.addChild(this.aimMc);
        this.cMc = this.getChildByName("c_mc") as MovieClip;
        this.cMc.gotoAndStop(this.color);
    }
    
    /**
     * 绘制一个泡泡显示对象
     * @param	bVo    泡泡数据
     */
    private function drawBubble(bVo:BubbleVo):void
    {
        if (!bVo) return;
		if (bVo.userData && bVo.userData is Sprite)
			Sprite(bVo.userData).graphics.clear();
		else bVo.userData = new Sprite();
        Sprite(bVo.userData).graphics.lineStyle(1, 0);
        Sprite(bVo.userData).graphics.beginFill(this.colorAry[bVo.color]);
        Sprite(bVo.userData).graphics.drawCircle(0, 0, bVo.radius);
        Sprite(bVo.userData).graphics.endFill();
        Sprite(bVo.userData).x = bVo.x;
        Sprite(bVo.userData).y = bVo.y;
        this.addChild(Sprite(bVo.userData));
    }
    
    /**
     * 销毁一个泡泡的显示对象
     * @param	bVo     泡泡数据
     */
    private function removeBubble(bVo:BubbleVo):void
    {
        if (!bVo) return;
        if (bVo.userData && bVo.userData is Sprite)
        {
            Sprite(bVo.userData).graphics.clear();
            if (Sprite(bVo.userData).parent)
                Sprite(bVo.userData).parent.removeChild(Sprite(bVo.userData));
            bVo.userData = null;
        }
    }
    
    /**
     * 渲染
     */
    private function render():void
    {
        if (!this.bubble) return;
        var arr:Array = this.bubble.getBubbleList();
        var length:int = arr.length;
        var bVo:BubbleVo;
        for (var i:int = 0; i < length; i += 1)
        {
            bVo = arr[i];
            if (bVo.userData && bVo.userData is DisplayObject)
            {
                Sprite(bVo.userData).x = bVo.x;
                Sprite(bVo.userData).y = bVo.y;
            }
        }
		
		//散开下落
		for each (bVo in this.fallList) 
		{
			bVo.x += bVo.vx;
			bVo.y += bVo.vy;
			bVo.vy += bVo.g;
			if (bVo.userData && bVo.userData is DisplayObject)
            {
                Sprite(bVo.userData).x = bVo.x;
                Sprite(bVo.userData).y = bVo.y;
            }
			if (bVo.y > this.bubble.range.bottom + bVo.radius)
			{
				this.removeBubble(bVo);
				delete this.fallList[bVo];
			}
		}
    }
    
    //销毁泡泡
    private function removeBubbleHandler(event:BubbleEvent):void 
    {
        //删除某个泡泡消息
		this.drawBubble(BubbleEvent(event).bVo);
		BubbleEvent(event).bVo.vx = Random.randnum( -2, 2);
		BubbleEvent(event).bVo.vy = Random.randnum(0, -4);
		BubbleEvent(event).bVo.g = 1;
		this.fallList[BubbleEvent(event).bVo] = BubbleEvent(event).bVo;
        //this.removeBubble(BubbleEvent(event).bVo);
    }
	
	
    //更新泡泡数据
	private function updateHandler(event:BubbleEvent):void 
	{
		trace(this.bubble.bubbleNum);
	}
    
    //点击事件
    private function mouseClickHander(event:MouseEvent):void 
    {
        this.cannon.aim(mouseX, mouseY);
        var vx:Number = Math.cos(this.cannon.angle) * this.cannon.power;
        var vy:Number = Math.sin(this.cannon.angle) * this.cannon.power;
        var bVo:BubbleVo = this.bubble.shotBubble(this.cannon.startX, this.cannon.startY - this.radius, vx, vy, this.color);
        this.drawBubble(bVo);
        this.color = Random.randint(1, this.colorType);
        this.cMc.gotoAndStop(this.color);
    }
	
	
	private function drawLineBubble(bubbleAry:Array):void
	{
		var bVo:BubbleVo;
		var length:int = bubbleAry.length;
		for (var i:int = 0; i < length; i += 1)
		{
			bVo = bubbleAry[i];
			this.drawBubble(bVo);
		}
	}
	
    
    //主循环
    private function loop(event:Event):void 
    {
        this.cannon.aim(mouseX, mouseY);
        this.aimMc.rotation = MathUtil.rds2dgs(this.cannon.angle);
		var t:Number = getTimer();
        this.bubble.update();
		var t2:Number = getTimer() -t;
		if (t2 > 0)
			trace(t2);
        this.render();
    }
}
}