# test functionality of NPoint module
require 'test/unit'
require 'bezier_curve/n_point'

class TestNPoint < Test::Unit::TestCase
  def test_to_np
    np = [9,8,7].to_np

    assert_kind_of  NPoint, np,   "Array#to_np should return an NPoint" 
    assert_same     np.to_np, np, "NPoint#to_np should return self"
  end
  def test_x
    np = [9,8,7].to_np
    assert_equal 9, np.x
  end
  def test_y
    np = [9,8,7].to_np
    assert_equal 8, np.y
  end
  def test_z
    np = [9,8,7].to_np
    assert_equal 7, np.z
  end
  def test_to
    a, b = [1,1,1].to_np, [5,5,5].to_np

    assert_equal [3,3,3], a.to(b,0.5)
    assert_equal [-1,-1,-1], a.to(b,-0.5)
    assert_equal [7,7,7], a.to(b,1.5)
  end
  def test_dist_from
    # various numbers of dimensions
    assert_equal 3,             [3].to_np.dist_from([6])
    assert_equal (3**2*2)**0.5, [3,3].to_np.dist_from([6,6])
    assert_equal (3**2*3)**0.5, [3,3,3].to_np.dist_from([6,6,6])
    assert_equal (3**2*4)**0.5, [3,3,3,3].to_np.dist_from([6,6,6,6])
    assert_equal (3**2*5)**0.5, [3,3,3,3,3].to_np.dist_from([6,6,6,6,6])

    # across the origin
    assert_in_delta  8**0.5, [1,1].to_np.dist_from([-1,-1]), 0.00001
  end
  def test_angle_to
    pi = Math::PI
    pi_eps = (pi.next_float-pi)*16
    assert_in_epsilon pi/2,  [1,0].to_np.angle_to([0,0],[0,1]),   pi_eps
    assert_in_epsilon pi,    [1,1].to_np.angle_to([0,0],[1,1]),   pi_eps
    assert_in_epsilon 0,     [1,1].to_np.angle_to([0,0],[-1,-1]), pi_eps
    assert_in_epsilon pi/4,  [-1,0].to_np.angle_to([0,0],[1,1]),  pi_eps
  end
end

