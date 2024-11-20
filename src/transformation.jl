################################################################################
### Barycentric Transformation
################################################################################

"""
    Barycentric

This struct defines a general barycentric-to-cartesian transformation, i.e.

TODO: need to add proper text. Currently, this is just a placeholder.
- would be great to have general triangles here, not just a equilateral one!
"""
struct Barycentric end
Barycentric(x) = Barycentric() #TODO: just a placeholder
Base.broadcastable(x::Barycentric) = (x,)

function Makie.apply_transform(trans::Barycentric, point::VecTypes{3, T}) where T <: Real
    a, b, c = point    
    return bary2cartesian(a, b, c)
end

# # Point2 may get expanded to Point3. In that case we leave z untransformed
# function apply_transform(f::Barycentric, point::VecTypes{N2, T}) where {N2, T}
#     p_dim = to_ndim(Point2{T}, point, 0.0)
#     p_trans = apply_transform(f, p_dim)
#     if 2 < N2
#         p_large = ntuple(i-> i <= 2 ? p_trans[i] : point[i], N2)
#         return Point{N2, T}(p_large)
#     else
#         return to_ndim(Point{N2, T}, p_trans, 0.0)
#     end
# end

# For bbox
#TODO: FIX
function Makie.apply_transform(trans::Barycentric, bbox::Rect3d)
    if trans.theta_as_x
        θmin, rmin, zmin = minimum(bbox)
        θmax, rmax, zmax = maximum(bbox)
    else
        rmin, θmin, zmin = minimum(bbox)
        rmax, θmax, zmax = maximum(bbox)
    end
    bb2d = TernaryAxis_bbox((rmin, rmax), (θmin, θmax), trans.r0, trans.direction, trans.theta_0)
    o = minimum(bb2d); w = widths(bb2d)
    return Rect3d(to_ndim(Point3d, o, zmin), to_ndim(Vec3d, w, zmax - zmin))
end

function Makie.inverse_transform(trans::Barycentric)    
    return Makie.PointTrans{2}() do point
        cartesian2bar(point...)
    end
end


# this is a simplification which will only really work with non-rotated or
# scaled scene transformations, but for 2D scenes this should work well enough.
# and this way we can use the z-value as a means to shift the drawing order
# by translating e.g. the axis spines forward so they are not obscured halfway
# by heatmaps or images
zvalue2d(x)::Float32 = Float32(Makie.translation(x)[][3] + zvalue2d(x.parent))
zvalue2d(::Nothing)::Float32 = 0f0