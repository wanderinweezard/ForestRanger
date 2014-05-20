require 'gosu'

module ZOrder
	Background, Entities, UI = *0..2
end

module GameConstants
	ScreenWidth  = 600
	ScreenHeight = 300

	PlayerHeight = 24
	PlayerWidth = 21 

	TileHeight = 4
	TileWidth  = 8

	ItemHeight = 8
	ItemWidth  = 8

	SpriteFactor = 3.0

	module Text
		Caption = "Forest Ranger"
	end

	module ItemIndexes
		Arrow     = 0
		FireArrow = 1
		Heart     = 2
		HalfHeart = 3
		Meat      = 4
		Shield    = 5
		Spear     = 6
		Longbow   = 7
		Longbow2  = 8
		Longbow3  = 9
		Dagger    = 10
		Torch     = 11
	end
	
	module EnemyIndexes
		Shadow = 0
		Unarmored = 1
		GoblinSpear = 2
		GoblinSword = 3
		GoblinBow = 4
		GoblinHammer = 5
		OrcSpear = 6
		OrcSword = 7
		OrcBow = 8
		OrcHammer = 9
	end
end

class Game < Gosu::Window

	def initialize
		super GameConstants::ScreenWidth, GameConstants::ScreenHeight, false
		self.caption = GameConstants::Text::Caption

		@ranger = Ranger.new(self, 0, 0)

		# load assets
		@item_images = Gosu::Image.load_tiles(self, "media/items.bmp", GameConstants::ItemWidth, GameConstants::ItemHeight, false)
		@enemy_images = Gosu::Image.load_tiles(self, "media/enemies.bmp", GameConstants::ItemWidth, GameConstants::ItemHeight, false)
		
		@projectiles = Array.new
		@arrow_cooldown = 0
		@dagger_cooldown = 0
		
		@enemies = Array.new
		@enemy_cooldown = 0
		
		Gosu::enable_undocumented_retrofication
	end

	def update
		move_x = move_y = 0

		if button_down? Gosu::KbUp then
			move_y -= @ranger.height
		end

		if button_down? Gosu::KbDown then
			move_y += @ranger.height
		end

		if button_down? Gosu::KbA then
			if @arrow_cooldown == 0 then
				@projectiles.push(Projectile.new(self, @item_images[GameConstants::ItemIndexes::Arrow], @ranger.x + 50, @ranger.y + (@ranger.height / 2)))
				@arrow_cooldown = 20
			end
			
			if @arrow_cooldown > 0 then
				@arrow_cooldown -= 1
			end
		end
		
		if button_down? Gosu::KbD then
			if @dagger_cooldown == 0 then
				@projectiles.push(Projectile.new(self, @item_images[GameConstants::ItemIndexes::Dagger], @ranger.x + 50, @ranger.y + (@ranger.height / 2)))
				@dagger_cooldown = 20
			end
			
			if @dagger_cooldown > 0 then
				@dagger_cooldown -= 1
			end
		end
		
		@ranger.move(move_x, move_y)
		@projectiles.each { |item| item.move(10) }
		
		@projectiles.reject! do |item|
		  if item.x > GameConstants::ScreenWidth then
			true
		  else
		    false
		  end
		end
		
		if @enemy_cooldown <= 0 then
		  @enemy_cooldown = 20
		  
		  @enemies.push(Enemy.new(self, @enemy_images[rand(10)], GameConstants::ScreenWidth - 8, rand(GameConstants::ScreenHeight)))
		end
		
		@enemy_cooldown -= 5
		@enemies.each { |enemy| enemy.move(2) }
	end

	def draw
		@ranger.draw

		x = 0
		@item_images.each { |item| item.draw(x, 80, ZOrder::Entities, GameConstants::SpriteFactor, GameConstants::SpriteFactor); x += (10 * GameConstants::SpriteFactor)}
		x = 0
		@enemy_images.each { |item| item.draw(x, 150, ZOrder::Entities, GameConstants::SpriteFactor, GameConstants::SpriteFactor); x += (10 * GameConstants::SpriteFactor)}
		
		@projectiles.each { |item| item.draw }
		@enemies.each { |item| item.draw }
	end

	def button_down(id)
		if id == Gosu::KbEscape
			close
		end
	end

end

class Ranger
	attr_reader :x, :y

	def initialize(window, x, y)
		@cur_image = Gosu::Image.new(window, "media/ranger.bmp", false)
		@x, @y = x, y
	end

	def draw
		@cur_image.draw(@x, @y, ZOrder::Entities, GameConstants::SpriteFactor, GameConstants::SpriteFactor)
	end

	def move(x, y)
		@x += x
		@y += y
	end

	def height
		@cur_image.height
	end

	def width
		@cur_image.width
	end

end

class Projectile
	attr_reader :x, :y

	def initialize(window, image, x, y)
		@cur_image = image
		@x, @y = x, y
	end

	def move(x)
		@x += x
	end

	def draw
		@cur_image.draw_rot(x, y, ZOrder::Entities, 45.0, 0.5, 0.5, GameConstants::SpriteFactor, GameConstants::SpriteFactor)
	end
end

class Enemy
	attr_reader :x, :y
	
	def initialize(window, image, x, y)
		@cur_image = image
		
		if y < 8 then
		  y = 8
		end
		#if (y + self.height) > GameConstants::ScreenHeight then
		#  y = GameConstants::ScreenHeight - self.height
		#end
		
		@x, @y, = x, y
	end
	
	def move(x)
		@x -= x
	end
	
	def draw
		@cur_image.draw_rot(x, y, ZOrder::Entities, 1.0, 1.0, 1.0, -GameConstants::SpriteFactor, GameConstants::SpriteFactor)
	end
	
	def attack
		nil
	end
end

window = Game.new
window.show