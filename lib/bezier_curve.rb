# bezier_curve.rb
# A bézier curve library for Ruby, supporting n-dimensional,
# nth-degree curves.

# A bezier curve. Usage:
#   c = BezierCurve.new([0,0], [0,1], [1,1])
#   c.first             #=> [0,0]
#   c.last              #=> [1,1]
#   c[0.375]            #=> [t=.375]
#   c.points            #=> an array of points that make a fairly smooth curve
#   c.points(tolerance:Math::PI/20)
#                       #=> returns points with given tolerance for smoothness
#   c.points(count: 10) #=> returns 10 points, for evenly spaced values of `t`
class BezierCurve
  # create a new curve, from a list of points.
  def initialize(*controls)
    raise "Minimum 2 control points (given #{controls.size})" unless 
      controls.size >= 2
    raise "All control points must have the same number of dimensions" unless 
      controls[1..-1].all?{|c|controls.first.size == c.size}
    @controls = controls.map(&:to_np)
  end

  attr_reader :controls

  # the first control point
  def first() controls.first; end
  alias_method :start, :first
  # the last control point
  def last()  controls.last;  end
  alias_method :end, :last
  
  # the degree of the curve
  def degree
    controls.size - 1
  end
  alias_method :order, :degree
  # the number of dimensions given
  def dimensions
    controls[0].size
  end

  # find the point for a given value of `t`.
  def index(t)
    pts = controls
    while pts.size > 1
      pts = (0..pts.size-2).map do |i|
        pts[i].zip(pts[i+1]).map{|a,b| t*(b-a)+a}
      end
    end
    pts[0].to_np
  end
  alias_method :[], :index

  # divide this bezier curve into two curves, at the given `t`
  def split_at(t)
    pts = controls
    a,b = [pts.first],[pts.last]
    while pts.size > 1
      pts = (0..pts.size-2).map do |i|
        pts[i].zip(pts[i+1]).map{|a,b| t*(b-a)+a}
      end
      a<<pts.first
      b<<pts.last
    end
    [BezierCurve.new(*a), BezierCurve.new(*b.reverse)]
  end


  # Returns a list of points on this curve. If you specify `count`,
  # returns that many points, evenly spread over values of `t`.
  # If you specify `tolerance`, no adjoining line segments will
  # deviate from 180 by an angle of more than the value given (in
  # radians). If unspecified, defaults to `tolerance: 1/64pi` (~3 deg)
  def points(count:nil, tolerance:Math::PI/64)
    if count
      (0...count).map{|i| index i/(count-1.0)}
    else
      lines = subdivide(tolerance)
      lines.map{|seg|seg.first} + lines.last.last
    end
  end

  # recursively subdivides the curve until each is straight within the
  # given tolerance value, in radians
  def subdivide(tolerance)
    if is_straight?(tolerance)
      [self]
    else
      a,b = split_at(0.5)
      a.subdivide(tolerance) + b.subdivide(tolerance)
    end
  end


  # test this curve to see of it can be considered straight, optionally
  # within the given angular tolerance, in radians
  def is_straight?(tolerance)
    # sanity check for tolerance in radians
    if first.angle_to(index(0.5), last) <= tolerance
      # maximum wavyness is `degree` - 1; split at `degree` points
      pts = points(count:degree)
      # size-3, because we ignore the last 2 points as starting points;
      # check all angles against `tolerance`
      (0..pts.size-3).all? do |i|
        pts[i].angle_to(pts[i+1], pts[i+2]) < tolerance
      end
    end
  end
end

# Extends an array to treat it as an n-dimensional point. Should not
# occlude any original Array methods
module NPoint
  # calculates how far this point is from `other`
  def dist_from(other)
    raise "Dimension counts don't match! (%i and %i)" %[size,other.size] unless size == other.size
    zip(other).map{|a,b|(a-b)**2}.inject{|a,b|a+b}**0.5
  end
  # calculates the angle formed by this point and two others
  # in radians
  def angle_to(a,b)
    a,b = *[a,b].map(&:to_np)
    d0,d1 = dist_from(a), a.dist_from(b)
    z = self.to(a,1+d1/d0)
    dz = z.dist_from(b)
    Math.asin(dz/2/d1)*2
  end

  # calculates the new point on the vector of self->other, scaled by `t`.
  # t=0 returns `self`, t=.5 is the midpoint, t=1 is `other`.
  def to(other, t)
    self.zip(other).map{|a,b|t*(b-a)+a}.to_np
  end

  # convert to NPoint; returns self
  def to_np
    self
  end

  # get the x value
  def x() self[0]; end
  # get the y value
  def y() self[1]; end
  # get the z value
  def z() self[2]; end
end


class Array
  # add n-point functions to a copy of this array
  def to_np
    dup.extend NPoint
  end
end
