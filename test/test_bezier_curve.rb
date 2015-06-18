# test functionality of BezierCurve class
require 'test/unit'
require 'bezier_curve'

class TestBezierCurve < Test::Unit::TestCase
  # shorthand to create a bezier curve
  def bc(*args)
    BezierCurve.new(*args)
  end

  def test_degree
    assert_equal 2, bc([0,0],[0,1],[1,1]).degree
    assert_equal 3, bc([0,0],[0,1],[1,0],[1,1]).degree
  end

  def test_dimensions
    assert_equal 2, bc([0,0],[0,1],[1,1]).dimensions
    assert_equal 3, bc([0,0,0],[0,1,1],[1,1,2]).dimensions
  end

  def test_index
    # simple curves that cross the origin
    # degree 1
    assert_equal [0,0], bc([1,1],[-1,-1])[0.5]
    assert_equal [0,0,0], bc([1,1,1],[-1,-1,-1])[0.5]
    assert_equal [0,0,0,0], bc([1,1,1,1],[-1,-1,-1,-1])[0.5]
    assert_equal [0,0,0,0,0], bc([1,1,1,1,1],[-1,-1,-1,-1,-1])[0.5]
    # degree 2 (quadratic)
    assert_equal [0,0], bc([1,1],[0,-1],[-1,1])[0.5]
    assert_equal [0,0,0], bc([1,1,1],[0,0,-1],[-1,-1,1])[0.5]
    assert_equal [0,0,0,0], bc([1,1,1,1],[0,0,0,-1],[-1,-1,-1,1])[0.5]
    assert_equal [0,0,0,0,0], bc([1,1,1,1,1],[0,0,0,0,-1],[-1,-1,-1,-1,1])[0.5]
    # degree 3 (cubic)
    assert_equal [0,0], bc([1,1],[-1,1],[1,-1],[-1,-1])[0.5]
    assert_equal [0,0,0], bc([1,1,1],[-1,1,1],[1,-1,-1],[-1,-1,-1])[0.5]
    assert_equal [0,0,0,0], bc([1,1,1,1],[-1,1,1,1],[1,-1,-1,-1],[-1,-1,-1,-1])[0.5]
    assert_equal [0,0,0,0,0], bc([1,1,1,1,1],[-1,1,1,1,1],[1,-1,-1,-1,-1],[-1,-1,-1,-1,-1])[0.5]
  end
  def test_split_at
    # not going to test specific points, just that the resulting curves are the same
    # degree 1
    c = bc([23,42],[13,7])
    _c1, _c2 = *c.split_at(0.25)
    assert_equal c.points(count:9), _c1.points(count:3)[0,2] + _c2.points(count:7)
    # degree 2
    c = bc([23,42],[13,7])
    _c1, _c2 = *c.split_at(0.25)
    assert_equal c.points(count:9), _c1.points(count:3)[0,2] + _c2.points(count:7)
    # degree 3
    c = bc([23,42,],[13,7],[12,54])
    _c1, _c2 = *c.split_at(0.25)
    assert_equal c.points(count:9), _c1.points(count:3)[0,2] + _c2.points(count:7)
    # degree 4
    c = bc([23,42],[13,7],[12,54],[103,144])
    _c1, _c2 = *c.split_at(0.25)
    assert_equal c.points(count:9), _c1.points(count:3)[0,2] + _c2.points(count:7)
    # degree 5
    c = bc([23,42],[13,7],[12,54],[103,144],[512,360])
    _c1, _c2 = *c.split_at(0.25)
    assert_equal c.points(count:9), _c1.points(count:3)[0,2] + _c2.points(count:7)
  end
  # does this really need testing? I really hope not. Oh well.
  def test_points_count
    # 1d,o1
    [2,3,5,8,13,23].each do |n|
      assert_equal n, bc([0,0],[1,1]).points(count:n).count
    end
    # 2d,o2
    [2,3,5,8,13,23].each do |n|
      assert_equal n, bc([0,0,0],[1,1,1],[2,2,2]).points(count:n).count
    end
    # 3d,o3
    [2,3,5,8,13,23].each do |n|
      assert_equal n, bc(*4.times.map{|n|Array.new(4).fill(n)}).points(count:n).count
    end
    # 4d,o4
    [2,3,5,8,13,23].each do |n|
      assert_equal n, bc(*5.times.map{|n|Array.new(5).fill(n)}).points(count:n).count
    end
    # 5d,o5
    [2,3,5,8,13,23].each do |n|
      assert_equal n, bc(*6.times.map{|n|Array.new(6).fill(n)}).points(count:n).count
    end
  end

  def test_points_tolerance
    pi = Math::PI
    # just make sure all points are under tolerance
    # 2d/o
    p = bc([1,0],[3,2],[7,9]).points(tolerance:pi/53)
    assert_true (0..p.count-3).all?{|i|p[i].angle_to(p[i+1],p[i+2]).abs < pi/53}
    # 3d/o
    p = bc([1,0,2],[3,2,5],[7,9,8],[13,17,12]).points(tolerance:pi/53)
    assert_true (0..p.count-3).all?{|i|p[i].angle_to(p[i+1],p[i+2]).abs < pi/53}
    # 4d/o
    p = bc([1,0,2,-1],[3,2,5,4],[7,9,8,6],[13,17,12,15],[20,21,32,25]).points(tolerance:pi/53)
    assert_true (0..p.count-3).all?{|i|p[i].angle_to(p[i+1],p[i+2]).abs < pi/53}
    # 5d/o
    p = bc([1,0,2,-1,3],[3,2,5,4,6],[7,9,8,6,5],[13,17,12,15,14],[20,21,32,25,23],[34,33,47,39,52]).points(tolerance:pi/53)
    assert_true (0..p.count-3).all?{|i|p[i].angle_to(p[i+1],p[i+2]).abs < pi/53}
  end

end

