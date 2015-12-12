size = Integer(ARGV[0])
r    = Integer(ARGV[1])
g    = Integer(ARGV[2])
b    = Integer(ARGV[3])
method = ARGV[4] || 'scan'

def light_up(col, row, r, g, b)
  `curl -X POST "http://localhost:4567?col=#{col}&row=#{row}&r=#{r}&g=#{g}&b=#{b}" 2>/dev/null`
end

def scan(size, r, g, b)
  while true do
    size.times do |i|
      size.times do |j|
        light_up(i, j, r, g, b)
      end
    end
  end
end

def random(size, r, g, b)
  while true do
    light_up(
      rand(size),
      rand(size),
      r, g, b)
  end
end

send(method, size, r, g, b)
