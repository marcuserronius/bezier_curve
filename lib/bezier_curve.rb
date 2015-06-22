# bezier_curve.rb
# A bézier curve library for Ruby, supporting n-dimensional,
# nth-degree curves.

require 'bezier_curve/version'
require 'bezier_curve/n_point'

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
    # check for argument errors
    ZeroDimensionError.check! controls
    DifferingDimensionError.check! controls
    InsufficientPointsError.check! controls

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
      lines.map{|seg|seg.first} + [lines.last.last]
    end
  end

  # recursively subdivides the curve until each is straight within the
  # given tolerance value, in radians. Then, subdivides further as
  # needed to remove remaining corners.
  def subdivide(tolerance)
    if is_straight? tolerance
      [self]
    else
      a,b = split_at(0.5).map{|c| c.subdivide(tolerance)}
      # now make sure the angle from a to b is good
      while a.last.first.angle_to(a.last.last,b.first.last) > tolerance
        if a.last.divergence > b.first.divergence
          a[-1,1] = a[-1].split_at(0.5)
        else
          b[0,1]  = b[0].split_at(0.5)
        end
      end
      a+b
    end
  end


  # test this curve to see of it can be considered straight, optionally
  # within the given angular tolerance, in radians
  def is_straight?(tolerance)
    # normal check for tolerance 
    if divergence <= tolerance
      # maximum wavyness is `degree` - 1; split at `degree` points
      pts = points(count:degree)
      # size-3, because we ignore the last 2 points as starting points;
      # check all angles against `tolerance`
      (0..pts.size-3).all? do |i|
        pts[i].angle_to(pts[i+1], pts[i+2]) < tolerance
      end
    else
      false
    end
  end

  # How much this curve diverges from straight, measuring from `t=0.5`
  def divergence
    first.angle_to(self[0.5],last)
  end

  # Indicates an error where the control points are in zero dimensions.
  # Sounds silly, but you never know, when software is generating the
  # points.
  class ZeroDimensionError < ArgumentError
    def initialize
      super "Points given must have at least one dimension"
    end
    def self.check! pointset
      raise self if
        pointset[0].size == 0
    end
  end

  # Indicates that the points do not all have the same number of
  # dimensions, which makes them impossible to use.
  class DifferingDimensionError < ArgumentError
    def initialize
      super "All points must have the same number of dimensions"
    end
    def self.check! pointset
      raise self if
        pointset[1..-1].any?{|pt| pointset[0].size != pt.size}
    end
  end

  # Indicates that there aren't enough control points; minimum of two
  # for a first-degree bezier.
  class InsufficientPointsError < ArgumentError
    def initialize
      super "You must supply a minimum of two points"
    end
    def self.check! pointset
      raise self if
        pointset.size <= 1
    end
  end
end
