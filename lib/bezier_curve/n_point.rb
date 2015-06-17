# bezier_curve/n_point.rb

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
