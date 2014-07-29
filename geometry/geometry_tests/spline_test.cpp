#include "../../base/SRC_FIRST.hpp"
#include "../../testing/testing.hpp"
#include "equality.hpp"
#include "../spline.hpp"

using m2::Spline;
using m2::PointF;

void TestPointFDir(PointF const & dst, PointF const & src)
{
  float len1 = dst.Length();
  float len2 = src.Length();
  TEST_ALMOST_EQUAL(dst.x/len1, src.x/len2, ());
  TEST_ALMOST_EQUAL(dst.y/len1, src.y/len2, ());
}

UNIT_TEST(SmoothedDirections)
{
  vector<PointF> path;
  path.push_back(PointF(0, 0));
  path.push_back(PointF(40, 40));
  path.push_back(PointF(80, 0));

  Spline spl;
  spl.FromArray(path);
  float const sqrt2 = sqrtf(2.0f);
  Spline::iterator itr;
  PointF dir1(sqrt2 / 2.0f, sqrt2 / 2.0f);
  PointF dir2(sqrt2 / 2.0f, -sqrt2 / 2.0f);
  itr.Attach(spl);
  TestPointFDir(itr.m_avrDir, dir1);
  itr.Step(sqrt2 * 30.0f);
  TestPointFDir(itr.m_avrDir, dir1);
  itr.Step(sqrt2 * 40.0f);
  TestPointFDir(itr.m_avrDir, dir1 * 0.25f + dir2 * 0.75f);
  itr.Step(sqrt2 * 10.0f);
  TestPointFDir(itr.m_avrDir, dir2);

  path.clear();

  path.push_back(PointF(0, 0));
  path.push_back(PointF(40, 40));
  path.push_back(PointF(80, 40));
  path.push_back(PointF(120, 0));

  PointF dir12(1.0f, 0.0f);
  Spline spl2;
  spl2.FromArray(path);
  itr.Attach(spl2);
  TestPointFDir(itr.m_avrDir, dir1);
  itr.Step(sqrt2 * 80.0f + 40.0f);
  TestPointFDir(itr.m_avrDir, dir12);
  itr.Attach(spl2);
  itr.Step(sqrt2 * 40.0f);
  TestPointFDir(itr.m_avrDir, dir1);
  itr.Step(80.0f);
  TestPointFDir(itr.m_avrDir, dir12 * 0.5f + dir2 * 0.5f);
}

UNIT_TEST(UsualDirections)
{
  vector<PointF> path;
  path.push_back(PointF(0, 0));
  path.push_back(PointF(40, 40));
  path.push_back(PointF(80, 0));

  Spline spl;
  spl.FromArray(path);
  float const sqrt2 = sqrtf(2.0f);
  Spline::iterator itr;
  PointF dir1(sqrt2 / 2.0f, sqrt2 / 2.0f);
  PointF dir2(sqrt2 / 2.0f, -sqrt2 / 2.0f);
  itr.Attach(spl);
  TestPointFDir(itr.m_dir, dir1);
  itr.Step(sqrt2 * 30.0f);
  TestPointFDir(itr.m_dir, dir1);
  itr.Step(sqrt2 * 40.0f);
  TestPointFDir(itr.m_dir, dir2);

  path.clear();

  path.push_back(PointF(0, 0));
  path.push_back(PointF(40, 40));
  path.push_back(PointF(80, 40));
  path.push_back(PointF(120, 0));

  PointF dir12(1.0f, 0.0f);
  Spline spl2;
  spl2.FromArray(path);
  itr.Attach(spl2);
  TestPointFDir(itr.m_dir, dir1);
  itr.Step(sqrt2 * 80.0f + 35.0f);
  TestPointFDir(itr.m_dir, dir2);
  itr.Attach(spl2);
  itr.Step(sqrt2 * 45.0f);
  TestPointFDir(itr.m_dir, dir12);
  itr.Step(80.0f);
  TestPointFDir(itr.m_dir, dir2);
}

UNIT_TEST(Positions)
{
  vector<PointF> path;
  path.push_back(PointF(0, 0));
  path.push_back(PointF(40, 40));
  path.push_back(PointF(80, 0));

  Spline spl;
  Spline spl0;
  Spline spl4;
  spl.FromArray(path);
  spl0 = spl4 = spl;
  float const sqrt2 = sqrtf(2.0f);
  Spline::iterator itr;
  itr.Attach(spl0);
  TestPointFDir(itr.m_pos, PointF(0, 0));
  itr.Step(sqrt2 * 40.0f);
  TestPointFDir(itr.m_pos, PointF(40, 40));
  itr.Step(sqrt2 * 40.0f);
  TestPointFDir(itr.m_pos, PointF(80, 0));
  itr.Attach(spl4);
  TestPointFDir(itr.m_pos, PointF(0, 0));
  itr.Step(sqrt2 * 40.0f);
  TestPointFDir(itr.m_pos, PointF(40, 40));
  itr.Step(sqrt2 * 40.0f);
  TestPointFDir(itr.m_pos, PointF(80, 0));

  path.clear();

  path.push_back(PointF(0, 0));
  path.push_back(PointF(40, 40));
  path.push_back(PointF(80, 40));
  path.push_back(PointF(120, 0));

  Spline spl2;
  spl2.FromArray(path);
  Spline spl3 = spl2;
  itr.Attach(spl3);
  TestPointFDir(itr.m_pos, PointF(0, 0));
  itr.Step(sqrt2 * 80.0f + 40.0f);
  TestPointFDir(itr.m_pos, PointF(120, 0));
  itr.Attach(spl2);
  itr.Step(sqrt2 * 40.0f);
  TestPointFDir(itr.m_pos, PointF(40, 40));
  itr.Step(2.0f);
  TestPointFDir(itr.m_pos, PointF(42, 40));
  itr.Step(20.0f);
  TestPointFDir(itr.m_pos, PointF(62, 40));
  itr.Step(18.0f);
  TestPointFDir(itr.m_pos, PointF(80, 40));
}

UNIT_TEST(BeginAgain)
{
  vector<PointF> path;
  path.push_back(PointF(0, 0));
  path.push_back(PointF(40, 40));
  path.push_back(PointF(80, 0));

  Spline spl;
  spl.FromArray(path);
  float const sqrt2 = sqrtf(2.0f);
  Spline::iterator itr;
  PointF dir1(sqrt2 / 2.0f, sqrt2 / 2.0f);
  PointF dir2(sqrt2 / 2.0f, -sqrt2 / 2.0f);
  itr.Attach(spl);
  TEST_EQUAL(itr.beginAgain(), false, ());
  itr.Step(90.0f);
  TEST_EQUAL(itr.beginAgain(), false, ());
  itr.Step(90.0f);
  TEST_EQUAL(itr.beginAgain(), true, ());
  itr.Step(190.0f);
  TEST_EQUAL(itr.beginAgain(), true, ());

  path.clear();

  path.push_back(PointF(0, 0));
  path.push_back(PointF(40, 40));
  path.push_back(PointF(80, 40));
  path.push_back(PointF(120, 0));

  Spline spl2;
  spl2.FromArray(path);
  itr.Attach(spl2);
  TEST_EQUAL(itr.beginAgain(), false, ());
  itr.Step(90.0f);
  TEST_EQUAL(itr.beginAgain(), false, ());
  itr.Step(90.0f);
  TEST_EQUAL(itr.beginAgain(), true, ());
  itr.Step(190.0f);
  TEST_EQUAL(itr.beginAgain(), true, ());
}

