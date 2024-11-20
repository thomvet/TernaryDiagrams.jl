################################################################################
### Main Block Intialization
################################################################################

function Makie.initialize_block!(po::TernaryAxis; palette=nothing)
    # Setup Scenes
    cb = po.layoutobservables.computedbbox
    scenearea = map(po.blockscene, cb) do cb
        return Rect(round.(Int, minimum(cb)), round.(Int, widths(cb)))
    end

    po.scene = Scene(
        po.blockscene, scenearea, backgroundcolor = po.backgroundcolor, clear = true
    )
    map!(to_color, po.scene, po.scene.backgroundcolor, po.backgroundcolor)

    po.overlay = Scene(
        po.scene, scenearea, clear = false, backgroundcolor = :transparent,
        transformation = Transformation(po.scene, transform_func = identity)
    )

    if !isnothing(palette)
        # Backwards compatibility for when palette was part of axis!
        palette_attr = palette isa Attributes ? palette : Attributes(palette)
        po.scene.theme.palette = palette_attr
    end

    # Setup camera/limits and Barycentric transform
    usable_fraction = setup_camera_matrices!(po)
    placeholder = Observable{String}("")
    Observables.connect!(
        po.scene.transformation.transform_func,
        @lift(Barycentric($placeholder))
    )
    Observables.connect!(
        po.overlay.transformation.transform_func,
        @lift(Barycentric($placeholder))
    )

    # Draw clip, grid lines, spine, ticks
    aticklabelplot, bticklabelplot, cticklabelplot = draw_axis!(po)

    # # Calculate fraction of screen usable after reserving space for theta ticks
    # # TODO: Should we include rticks here?
    # # OPT: only update on relevant text attributes rather than glyphcollection
    # onany(
    #         po.blockscene,
    #         rticklabelplot.plots[1].text,
    #         rticklabelplot.plots[1].fontsize,
    #         rticklabelplot.plots[1].font,
    #         po.rticklabelpad,
    #         thetaticklabelplot.plots[1].text,
    #         thetaticklabelplot.plots[1].fontsize,
    #         thetaticklabelplot.plots[1].font,
    #         po.thetaticklabelpad,
    #         po.overlay.viewport
    #     ) do _, _, _, rpad, _, _, _, tpad, area

    #     # get maximum size of tick label
    #     # (each boundingbox represents a string without text.position applied)
    #     max_widths = Vec2f(0)
    #     for gc in thetaticklabelplot.plots[1].plots[1][1][]
    #         bbox = string_boundingbox(gc, Quaternionf(0, 0, 0, 1)) # no rotation
    #         max_widths = max.(max_widths, widths(bbox)[Vec(1,2)])
    #     end
    #     for gc in rticklabelplot.plots[1].plots[1][1][]
    #         bbox = string_boundingbox(gc, Quaternionf(0, 0, 0, 1)) # no rotation
    #         max_widths = max.(max_widths, widths(bbox)[Vec(1,2)])
    #     end

    #     max_width, max_height = max_widths

    #     space_from_center = 0.5 .* widths(area)
    #     space_for_ticks = 2max(rpad, tpad) .+ (max_width, max_height)
    #     space_for_axis = space_from_center .- space_for_ticks

    #     # divide by width only because aspect ratios
    #     usable_fraction[] = space_for_axis ./ space_from_center[1]
    # end

    # # Set up the title position
    # title_position = map(
    #         po.blockscene,
    #         po.target_alims, po.target_blims, po.target_clims, 
    #         po.aticklabelsize, po.bticklabelsize, po.cticklabelsize, 
    #         po.aticklabelpad, po.bticklabelpad, po.cticklabelpad,
    #         po.overlay.viewport, po.overlay.camera.projectionview,
    #         po.titlegap, po.titlesize, po.titlealign
    #     ) do alims, blims, clims, a_fs, b_fs, c_fs, a_pad, b_pad, c_pad, area, pv, gap, size, align

    #     # derive y position
    #     # transform to pixel space
    #     w, h = widths(area)
    #     m = 0.5h * pv[2, 2]
    #     b = 0.5h * (pv[2, 4] + 1)

    #     # thetamin, thetamax = extrema(dir .* (thetalims .+ theta_0))
    #     # if thetamin - div(thetamax - 0.5pi, 2pi, RoundDown) * 2pi < 0.5pi
    #     #     # clip at 1 in overlay scene
    #     #     # theta fontsize & pad relevant
    #     #     ypx = (m * 1.0 + b) + (2t_pad + t_fs + gap)
    #     # else
    #     #     y1 = sin(thetamin); y2 = sin(thetamax)
    #     #     rscale = rlims[1] / rlims[2]
    #     #     y = max(rscale * y1, rscale * y2, y1, y2)
    #     #     ypx = (m * y + b) + (2max(t_pad, r_pad) + max(t_fs, r_fs) + gap)
    #     # end
        
    #     #TODO: just a hack right now
    #     ypx = 100.0

    #     xpx::Float32 = if align === :center
    #         area.origin[1] + w / 2
    #     elseif align === :left
    #         area.origin[1]
    #     elseif align === :right
    #         area.origin[1] + w
    #     elseif align isa Real
    #         area.origin[1] + align * w
    #     else
    #         error("Title align $align not supported.")
    #     end
    #     @show ypx, xpx
    #     return Point2f(xpx, area.origin[2] + ypx)
    # end

    # titleplot = text!(
    #     po.blockscene,
    #     title_position;
    #     text = po.title,
    #     font = po.titlefont,
    #     fontsize = po.titlesize,
    #     color = po.titlecolor,
    #     align = @lift(($(po.titlealign), :bottom)),
    #     visible = po.titlevisible,
    # )
    # translate!(titleplot, 0, 0, 9100) # Make sure this draws on top of clip

    # # Protrusions are space reserved for ticks and labels outside `scenearea`.
    # # Since we handle ticks within out `scenearea` this only needs to reserve
    # # space for the title
    # protrusions = map(
    #         po.blockscene, po.title, po.titlegap, po.titlesize
    #     ) do title, gap, size
    #     titlespace = po.title[] == "" ? 0f0 : Float32(2gap + size)
    #     return GridLayoutBase.RectSides(0f0, 0f0, 0f0, titlespace)
    # end

    # connect!(po.layoutobservables.protrusions, protrusions)

    return
end


################################################################################
### Camera and Controls
################################################################################

function bary2cartesian(a, b, c)
    x = 1/2*(2*b + c)/(a + b + c)
    y = sqrt(3)/2*c/(a + b + c)
    return Point2{eltype(a*b*c)}(x, y)
end

function cartesian2bary(x, y)    
    Point3{eltype(x*y)}((invR * [1, x, y])...) #TODO: this is badly allocating, but whatever at this stage...
end

# Bounding box specified by limits in Cartesian coordinates
function TernaryAxis_bbox(alims, blims, clims)
    @show alims
    amin, amax = alims
    bmin, bmax = blims
    cmin, cmax = clims

    # Initial bbox from corners
    p = bary2cartesian(amin, bmin, cmin)
    bb = Rect2d(p, Vec2d(0))
    bb = update_boundingbox(bb, bary2cartesian(amin, bmax, cmin))
    bb = update_boundingbox(bb, bary2cartesian(amin, bmin, cmax))
    return bb
end

function setup_camera_matrices!(po::TernaryAxis)
    # Initialization
    usable_fraction = Observable(Vec2d(1.0, 1.0))
    setfield!(po, :target_alims, Observable{Tuple{Float64, Float64}}((0.0, 1.0)))
    setfield!(po, :target_blims, Observable{Tuple{Float64, Float64}}((0.0, 1.0)))
    setfield!(po, :target_clims, Observable{Tuple{Float64, Float64}}((0.0, 1.0)))
    reset_limits!(po)
    onany((_, _, _) -> reset_limits!(po), po.blockscene, po.alimits, po.blimits, po.climits)

    # #get cartesian bbox defined by axis limits
    # data_bbox = map(
    #     TernaryAxis_bbox,
    #     po.blockscene,
    #     po.target_alims, po.target_blims, po.target_clims
    # )

    # # fit data_bbox into the usable area of TernaryAxis (i.e. with tick space subtracted)
    # onany(po.blockscene, usable_fraction, data_bbox) do usable_fraction, bb
    #     mini = minimum(bb); ws = widths(bb)
    #     @show bb, ws, mini
    #     scale = minimum(2usable_fraction ./ ws)
    #     trans = to_ndim(Vec3f, -scale .* (mini .+ 0.5ws), 0)
    #     camera(po.scene).view[] = transformationmatrix(trans, Vec3f(scale, scale, 1))
    #     return
    # end

    # # # same as above, but with rmax scaled to 1
    # # # OPT: data_bbox triggers on target_r0, target_rlims updates
    # onany(po.blockscene, usable_fraction, data_bbox) do usable_fraction, bb
    #     mini = minimum(bb); ws = widths(bb)
    #     rmax = 1.0 # po.target_rlims[][2] - po.target_r0[]
    #     scale = minimum(2usable_fraction ./ ws)
    #     trans = to_ndim(Vec3f, -scale .* (mini .+ 0.5ws), 0)
    #     scale *= rmax
    #     camera(po.overlay).view[] = transformationmatrix(trans, Vec3f(scale, scale, 1))
    # end

    max_z = 10_000f0

    # # update projection matrices
    # this just aspect-aware clip space (-1 .. 1, -h/w ... h/w, -max_z ... max_z)
    on(po.blockscene, po.scene.viewport) do area
        #aspect = Float32((/)(widths(area)...))
        w = 1.1f0
        h = Float32(sqrt(3)/2*1.1) #/ aspect
        camera(po.scene).projection[] = orthographicprojection(-0.1f0, w, -0.1f0, h, -max_z, max_z)
    end

    on(po.blockscene, po.overlay.viewport) do area
        #aspect = Float32((/)(widths(area)...))
        w = 1.1f0
        h = Float32(sqrt(3)/2*1.1) #/ aspect
        #@show aspect
        camera(po.overlay).projection[] = orthographicprojection(-0.1f0, w, -0.1f0, h, -max_z, max_z)
    end

    # Interactivity
    e = events(po.scene)

    # scroll to zoom 
    on(po.blockscene, e.scroll) do scroll
        if is_mouseinside(po.scene) 
            if ispressed(e, po.azoomkey[])
                amin, amax = po.target_alims[]
                zoom_step = po.zoomspeed[]*scroll[2]
                if ispressed(e, po.zoomdirectionkey[])
                    amax = min(amax + zoom_step, 1)
                else
                    amin = max(amin + zoom_step, 0)
                end
                po.target_alims[] = (amin, amax)
            end

            if ispressed(e, po.bzoomkey[])
                bmin, bmax = po.target_blims[]
                zoom_step = po.zoomspeed[]*scroll[2]
                if ispressed(e, po.zoomdirectionkey[])
                    bmax = min(bmax + zoom_step, 1)
                else
                    bmin = max(bmin + zoom_step, 0)
                end
                po.target_blims[] = (bmin, bmax)
            end

            if ispressed(e, po.czoomkey[])
                cmin, cmax = po.target_clims[]
                zoom_step = po.zoomspeed[]*scroll[2]
                if ispressed(e, po.zoomdirectionkey[])
                    cmax = min(cmax + zoom_step, 1)
                else
                    cmin = max(cmin + zoom_step, 0)
                end
                po.target_clims[] = (cmin, cmax)
            end
            Consume(true)
        else
            Consume(false)
        end
    end


    # e = events(po.scene)

    # # scroll to zoom
    # on(po.blockscene, e.scroll) do scroll
    #     if is_mouseinside(po.scene) && (!po.rzoomlock[] || !po.thetazoomlock[])
    #         mp = mouseposition(po.scene)
    #         r = norm(mp)
    #         zoom_scale = (1.0 - po.zoomspeed[]) ^ scroll[2]
    #         rmin, rmax = po.target_rlims[]
    #         thetamin, thetamax =  po.target_thetalims[]

    #         # keep circumference to radial length ratio constant by default
    #         dtheta = thetamax - thetamin
    #         aspect = r * dtheta / (rmax - rmin)

    #         # change in radial length
    #         dr = (zoom_scale - 1) * (rmax - rmin)

    #         # to keep the point under the cursor roughly in place we keep
    #         # r at the same percentage between rmin and rmax
    #         w = (r - rmin) / (rmax - rmin)

    #         # keep rmin at 0 when zooming near zero
    #         if rmin != 0 || r > 0.1rmax
    #             rmin = max(0, rmin - w * dr)
    #         end
    #         rmax = max(rmin + 100eps(rmin), rmax + (1 - w) * dr)

    #         if !ispressed(e, po.thetazoomkey[]) && !po.rzoomlock[]
    #             if po.fixrmin[]
    #                 rmin = po.target_rlims[][1]
    #                 rmax = max(rmin + 100eps(rmin), rmax + dr)
    #             end
    #             po.target_rlims[] = (rmin, rmax)
    #         end

    #         if abs(thetamax - thetamin) < 2pi

    #             # angle of mouse position normalized to range
    #             theta = po.direction[] * atan(mp[2], mp[1]) - po.target_theta_0[]
    #             thetacenter = 0.5 * (thetamin + thetamax)
    #             theta = mod(theta, thetacenter-pi .. thetacenter+pi)

    #             w = (theta - thetamin) / (thetamax - thetamin)
    #             dtheta = (thetamax - thetamin) - clamp(aspect * (rmax - rmin) / r, 0, 2pi)
    #             thetamin = thetamin + w * dtheta
    #             thetamax = thetamax - (1-w) * dtheta

    #             if !ispressed(e, po.rzoomkey[]) && !po.thetazoomlock[]
    #                 if po.normalize_theta_ticks[]
    #                     if thetamax - thetamin < 2pi - 1e-5
    #                         po.target_thetalims[] = normalize_thetalims(thetamin, thetamax)
    #                     else
    #                         po.target_thetalims[] = (0.0, 2pi)
    #                     end
    #                 else
    #                     po.target_thetalims[] = (thetamin, thetamax)
    #                 end
    #             end

    #         # don't open a gap when zooming a full circle near the center
    #         elseif r > 0.1rmax && zoom_scale < 1

    #             # open angle on the opposite site of theta
    #             theta = po.direction[] * atan(mp[2], mp[1]) - po.target_theta_0[]
    #             theta = theta + pi + thetamin # (-pi, pi) -> (thetamin, thetamin+2pi)

    #             dtheta = (thetamax - thetamin) - clamp(aspect * (rmax - rmin) / r, 1e-6, 2pi)
    #             thetamin = theta + 0.5 * dtheta
    #             thetamax = theta + 2pi - 0.5 * dtheta

    #             if !ispressed(e, po.rzoomkey[]) && !po.thetazoomlock[]
    #                 if po.normalize_theta_ticks[]
    #                     po.target_thetalims[] = normalize_thetalims(thetamin, thetamax)
    #                 else
    #                     po.target_thetalims[] = (thetamin, thetamax)
    #                 end
    #             end
    #         end

    #         return Consume(true)
    #     end
    #     return Consume(false)
    # end

    # # translation
    # drag_state = RefValue((false, false, false))
    # last_pos = RefValue(Point2f(0))
    # last_px_pos = RefValue(Point2f(0))
    # on(po.blockscene, e.mousebutton) do e
    #     if e.action == Mouse.press && is_mouseinside(po.scene)
    #         drag_state[] = (
    #             ispressed(po.scene, po.r_translation_button[]),
    #             ispressed(po.scene, po.theta_translation_button[]),
    #             ispressed(po.scene, po.axis_rotation_button[])
    #         )
    #         last_px_pos[] = Point2f(mouseposition_px(po.scene))
    #         last_pos[] = Point2f(mouseposition(po.scene))
    #         return Consume(any(drag_state[]))
    #     elseif e.action == Mouse.release
    #         was_pressed = any(drag_state[])
    #         drag_state[] = (
    #             ispressed(po.scene, po.r_translation_button[]),
    #             ispressed(po.scene, po.theta_translation_button[]),
    #             ispressed(po.scene, po.axis_rotation_button[])
    #         )
    #         return Consume(was_pressed)
    #     end
    #     return Consume(false)
    # end

    # on(po.blockscene, e.mouseposition) do _
    #     if drag_state[][3]
    #         w = widths(po.scene)
    #         p0 = (last_px_pos[] .- 0.5w) ./ w
    #         p1 = Point2f(mouseposition_px(po.scene) .- 0.5w) ./ w
    #         if norm(p0) * norm(p1) < 1e-6
    #             Δθ = 0.0
    #         else
    #             Δθ = mod(po.direction[] * (atan(p1[2], p1[1]) - atan(p0[2], p0[1])), -pi..pi)
    #         end

    #         po.target_theta_0[] = mod(po.target_theta_0[] + Δθ, 0..2pi)

    #         last_px_pos[] = Point2f(mouseposition_px(po.scene))
    #         last_pos[] = Point2f(mouseposition(po.scene))

    #     elseif drag_state[][1] || drag_state[][2]
    #         pos = Point2f(mouseposition(po.scene))
    #         diff = pos - last_pos[]
    #         r = norm(last_pos[])

    #         if r < 1e-6
    #             Δr = norm(pos)
    #             Δθ = 0.0
    #         else
    #             u_r = last_pos[] ./ r
    #             u_θ = Point2f(-u_r[2], u_r[1])
    #             Δr = dot(u_r, diff)
    #             Δθ = po.direction[] * dot(u_θ, diff ./ r)
    #         end

    #         if drag_state[][1] && !po.fixrmin[]
    #             rmin, rmax = po.target_rlims[]
    #             dr = min(rmin, Δr)
    #             po.target_rlims[] = (rmin - dr, rmax - dr)
    #         end
    #         if drag_state[][2]
    #             thetamin, thetamax = po.target_thetalims[]
    #             if thetamax - thetamin > 2pi - 1e-5
    #                 # full circle -> rotate view
    #                 po.target_theta_0[] = mod(po.target_theta_0[] + Δθ, 0..2pi)
    #             else
    #                 # partial circle -> rotate and adjust limits
    #                 thetamin, thetamax = (thetamin, thetamax) .- Δθ
    #                 if po.normalize_theta_ticks[]
    #                     po.target_thetalims[] = normalize_thetalims(thetamin, thetamax)
    #                 else
    #                     po.target_thetalims[] = (thetamin, thetamax)
    #                 end
    #                 po.target_theta_0[] = mod(po.target_theta_0[] + Δθ, 0..2pi)
    #             end
    #         end

    #         # Needs recomputation because target_radius may have changed
    #         last_px_pos[] = Point2f(mouseposition_px(po.scene))
    #         last_pos[] = Point2f(mouseposition(po.scene))
    #         return Consume(true)
    #     end
    #     return Consume(false)
    #end

    # Reset button
    # onany(po.blockscene, e.mousebutton, e.keyboardbutton) do e1, e2
    #     if ispressed(e, po.reset_button[]) && is_mouseinside(po.scene) &&
    #         (e1.action == Mouse.press) && (e2.action == Keyboard.press)
    #         old_thetalims = po.target_thetalims[]
    #         if ispressed(e, Keyboard.left_shift)
    #             autolimits!(po)
    #         else
    #             reset_limits!(po)
    #         end
    #         if po.reset_axis_orientation[]
    #             notify(po.theta_0)
    #         else
    #             diff = 0.5 * sum(po.target_thetalims[] .- old_thetalims)
    #             po.target_theta_0[] = mod(po.target_theta_0[] - diff, 0..2pi)
    #         end
    #         return Consume(true)
    #     end
    #     return Consume(false)
    # end

    return usable_fraction
end

function Makie.reset_limits!(po::TernaryAxis)
    # po.alimits[] = (0.0, 1.0)
    # po.blimits[] = (0.0, 1.0)
    # po.climits[] = (0.0, 1.0)
    # # Resolve automatic as origin
    # rmin_to_origin = po.rlimits[][1] === :origin
    # rlimits = ifelse.(rmin_to_origin, nothing, po.rlimits[])

    # # at least one derived limit
    # if any(isnothing, rlimits) || any(isnothing, po.thetalimits[])
    #     if !isempty(po.scene.plots)
    #         # TODO: Why does this include child scenes by default?

    #         # Generate auto limits
    #         lims2d = Rect2f(data_limits(po.scene, p -> !(p in po.scene.plots)))

    #         if po.theta_as_x[]
    #             thetamin, rmin = minimum(lims2d)
    #             thetamax, rmax = maximum(lims2d)
    #         else
    #             rmin, thetamin = minimum(lims2d)
    #             rmax, thetamax = maximum(lims2d)
    #         end

    #         # Determine automatic target_r0
    #         if po.radius_at_origin[] isa Real
    #             po.target_r0[] = po.radius_at_origin[]
    #         else
    #             po.target_r0[] = min(0.0, rmin)
    #         end

    #         # cleanup autolimits (0 width, rmin ≥ target_r0)
    #         if rmin == rmax
    #             if rmin_to_origin
    #                 rmin = po.target_r0[]
    #             else
    #                 rmin = max(po.target_r0[], rmin - 5.0)
    #             end
    #             rmax = rmin + 10.0
    #         else
    #             dr = rmax - rmin
    #             if rmin_to_origin
    #                 rmin = po.target_r0[]
    #             else
    #                 rmin = max(po.target_r0[], rmin - po.rautolimitmargin[][1] * dr)
    #             end
    #             rmax += po.rautolimitmargin[][2] * dr
    #         end

    #         dtheta = thetamax - thetamin
    #         if thetamin == thetamax
    #             thetamin, thetamax = (0.0, 2pi)
    #         elseif dtheta > 1.5pi
    #             thetamax = thetamin + 2pi
    #         else
    #             thetamin -= po.thetaautolimitmargin[][1] * dtheta
    #             thetamax += po.thetaautolimitmargin[][2] * dtheta
    #         end

    #     else
    #         # no plot limits, use defaults
    #         rmin = 0.0; rmax = 10.0; thetamin = 0.0; thetamax = 2pi
    #     end

    #     # apply
    #     po.target_rlims[]     = ifelse.(isnothing.(rlimits),          (rmin, rmax),         rlimits)
    #     po.target_thetalims[] = ifelse.(isnothing.(po.thetalimits[]), (thetamin, thetamax), po.thetalimits[])
    # else # all limits set
    #     if po.target_rlims[] != rlimits
    #         po.target_rlims[] = rlimits
    #     end
    #     if po.target_thetalims[] != po.thetalimits[]
    #         po.target_thetalims[] = po.thetalimits[]
    #     end
    # end

    if po.target_alims[] != po.alimits[]
        po.target_alims[] = po.alimits[]
    end 

    if po.target_blims[] != po.blimits[]
        po.target_blims[] = po.blimits[]
    end 

    if po.target_clims[] != po.climits[]
        po.target_clims[] = po.climits[]
    end 
    @show "hi"

    return
end


################################################################################
### Axis visualization - grid lines, clip, ticks
################################################################################


# generates large square with circle sector cutout
# function _polar_clip_polygon(
#         thetamin, thetamax, steps = 120, outer = 1e4,
#         exterior = Point2f[(-outer, -outer), (-outer, outer), (outer, outer), (outer, -outer), (-outer, -outer)]
#     )
#     # make sure we have 2+ points per arc
#     interior = map(theta -> polar2cartesian(1.0, theta), LinRange(thetamin, thetamax, steps))
#     (abs(thetamax - thetamin) ≈ 2pi) || push!(interior, Point2f(0))
#     return [Polygon(exterior, [interior])]
# end


function draw_axis!(po::TernaryAxis)
    atick_pos_lbl = Observable{Vector{<:Tuple{Any, Point3f}}}()
    atick_align = Observable{Point3f}()
    atick_offset = Observable{Point3f}()
    atick_rotation = Observable{Float32}()
    btick_pos_lbl = Observable{Vector{<:Tuple{Any, Point3f}}}()
    btick_align = Observable{Point3f}()
    btick_offset = Observable{Point3f}()
    btick_rotation = Observable{Float32}()
    ctick_pos_lbl = Observable{Vector{<:Tuple{Any, Point3f}}}()
    ctick_align = Observable{Point3f}()
    ctick_offset = Observable{Point3f}()
    ctick_rotation = Observable{Float32}()
    LSType = typeof(GeometryBasics.LineString(Point3f[]))
    agridpoints = Observable{Vector{LSType}}()
    aminorgridpoints = Observable{Vector{LSType}}()
    bgridpoints = Observable{Vector{LSType}}()
    bminorgridpoints = Observable{Vector{LSType}}()
    cgridpoints = Observable{Vector{LSType}}()
    cminorgridpoints = Observable{Vector{LSType}}()

    #observables for a gridlines and labels
    onany(
            po.blockscene,
            po.aticks, po.aminorticks, po.atickformat, po.target_alims, po.target_blims, po.target_clims
        ) do aticks, aminorticks, atickformat, alims, blims, clims

        # For text:
        _atickvalues, _aticklabels = get_ticks(aticks, identity, atickformat, alims...)
        I = findall(p -> p > 1 - blims[1] - clims[1], _atickvalues)
        deleteat!(_atickvalues, I)
        deleteat!(_aticklabels, I)
        _atick_a = _atickvalues
        #TODO: need adjustments in label positions, so that they don't overlap with gridlines/spines
        _atick_b = max.(1 .- _atick_a .- clims[2], 0, blims[1]) 
        _atick_c = 1 .- _atick_a .- _atick_b
        atick_pos_lbl[] = tuple.(_aticklabels, Point3f.(_atick_a, _atick_b, _atick_c))

        # For grid lines
        agridpoints[] = Makie.GeometryBasics.LineString.([[Point3f(a, max(blims[1], 0, 1-a-clims[2]), 1-a-max(blims[1], 0, 1-a-clims[2])), Point3f(a, min(blims[2], 1-a-clims[1]), 1-a-min(blims[2], 1-a-clims[1]))] for a in _atickvalues])
        _aminortickvalues = get_minor_tickvalues(aminorticks, identity, _atickvalues, alims...)
        aminorgridpoints[] = Makie.GeometryBasics.LineString.([[Point3f(a, 0, 1-a), Point3f(a, 1-a, 0)] for a in _aminortickvalues])
        return
    end

    #observables for b gridlines and labels
    onany(
            po.blockscene,
            po.bticks, po.bminorticks, po.btickformat, po.target_alims, po.target_blims, po.target_clims
        ) do bticks, bminorticks, btickformat, alims, blims, clims

        # For text
        _btickvalues, _bticklabels = get_ticks(bticks, identity, btickformat, blims...)
        I = findall(p -> p > 1 - alims[1] - clims[1], _btickvalues)
        deleteat!(_btickvalues, I)
        deleteat!(_bticklabels, I)
        _btick_b = _btickvalues
        _btick_a = min.(alims[2], 1 .- _btick_b .- clims[1]) 
        _btick_c = 1 .- _btick_a .- _btick_b 
        btick_pos_lbl[] = tuple.(_bticklabels, Point3f.(_btick_a, _btick_b, _btick_c))
        #TODO: need adjustments in label positions, so that they don't overlap with gridlines/spines
        #cart = bary2cartesian.(_btick_a, _btick_b, _btick_c)
        # bary = [cartesian2bary(Float32(p[1]), Float32(p[2]) - 0.03f0) for p in cart]
        # btick_pos_lbl[] = tuple.(_bticklabels, bary)
        # @show btick_pos_lbl[]
        # @show bary
        # @show bary[1]
        # @show typeof(bary[1])
        # @show _bticklabels

        # For grid lines
        bgridpoints[] = Makie.GeometryBasics.LineString.([[Point3f(max(0, alims[1], 1-b-clims[2]), b, 1-b-max(0, alims[1], 1-b-clims[2])), Point3f(min(alims[2], 1-b-clims[1]), b, 1-b-min(alims[2], 1-b-clims[1]))] for b in _btickvalues])
        _bminortickvalues = get_minor_tickvalues(bminorticks, identity, _btickvalues, blims...)
        bminorgridpoints[] = Makie.GeometryBasics.LineString.([[Point3f(0, b, 1-b), Point3f(1-b, b, 0)] for b in _bminortickvalues])
        return
    end

    #observables for c gridlines and labels
    onany(
            po.blockscene,
            po.cticks, po.cminorticks, po.ctickformat, po.target_alims, po.target_blims, po.target_clims, 
        ) do cticks, cminorticks, ctickformat, alims, blims, clims

        # For text:
        _ctickvalues, _cticklabels = get_ticks(cticks, identity, ctickformat, clims...)
        I = findall(p -> p > 1 - alims[1] - blims[1], _ctickvalues)
        deleteat!(_ctickvalues, I)
        deleteat!(_cticklabels, I)
        _ctick_c = _ctickvalues
        #TODO: need adjustments in label positions, so that they don't overlap with gridlines/spines
        _ctick_a = max.(alims[1], zeros(length(_ctick_c)), 1 .- _ctick_c .- blims[2]) 
        _ctick_b = 1 .- _ctick_c .- _ctick_a
        ctick_pos_lbl[] = tuple.(_cticklabels, Point3f.(_ctick_a, _ctick_b, _ctick_c))

        # For grid lines                                                                                                                                    
        cgridpoints[] = Makie.GeometryBasics.LineString.([[Point3f(max(alims[1], 0, 1-c-blims[2]), 1-c-max(alims[1], 0, 1-c-blims[2]), c), Point3f(min(alims[2], 1-c-blims[1]), 1-c-min(alims[2], 1-c-blims[1]), c)] for c in _ctickvalues])
        _cminortickvalues = get_minor_tickvalues(cminorticks, identity, _ctickvalues, clims...)
        cminorgridpoints[] = Makie.GeometryBasics.LineString.([[Point3f(0, 1-c, c), Point3f(1-c, 0, c)] for c in _cminortickvalues])
        return
    end

    # spine 
    spine_points = map(po.blockscene,
            po.target_alims, po.target_blims, po.target_clims
        ) do alims, blims, clims
        
        ps = zeros(Point3f, 15)
        ps[1] = Point3f(alims[1], blims[1], 1-alims[1]-blims[1])
        ps[1] = Point3f(alims[1], blims[1], 1-alims[1]-blims[1])
        cmin = max(0, clims[1])
        max(1-blims[1]-clims[1],0)
        max(1-blims[2]-clims[2],0)
        return ps
    end

    notify(po.aticks)
    notify(po.bticks)
    notify(po.cticks)

    # plot using the created observables

    # major grids
    agridplot = lines!(
        po.overlay, agridpoints;
        color = po.agridcolor,
        linestyle = po.agridstyle,
        linewidth = po.agridwidth,
        visible = po.agridvisible,
    )

    bgridplot = lines!(
        po.overlay, bgridpoints;
        color = po.bgridcolor,
        linestyle = po.bgridstyle,
        linewidth = po.bgridwidth,
        visible = po.bgridvisible,
    )

    cgridplot = lines!(
        po.overlay, cgridpoints;
        color = po.cgridcolor,
        linestyle = po.cgridstyle,
        linewidth = po.cgridwidth,
        visible = po.cgridvisible,
    )

    # minor grids
    aminorgridplot = lines!(
        po.overlay, aminorgridpoints;
        color = po.aminorgridcolor,
        linestyle = po.aminorgridstyle,
        linewidth = po.aminorgridwidth,
        visible = po.aminorgridvisible,
    )

    bminorgridplot = lines!(
        po.overlay, bminorgridpoints;
        color = po.bminorgridcolor,
        linestyle = po.bminorgridstyle,
        linewidth = po.bminorgridwidth,
        visible = po.bminorgridvisible,
    )

    cminorgridplot = lines!(
        po.overlay, cminorgridpoints;
        color = po.cminorgridcolor,
        linestyle = po.cminorgridstyle,
        linewidth = po.cminorgridwidth,
        visible = po.cminorgridvisible,
    )

    #spine 
    spineplot = lines!(
        po.overlay,
        spine_points,
        color = po.spinecolor,
        linewidth = po.spinewidth,
        linestyle = po.spinestyle,
        visible = po.spinevisible
    )

    # Clipping
    clipcolor = map(po.blockscene, po.clipcolor, po.backgroundcolor) do cc, bgc
        return cc === automatic ? RGBf(to_color(bgc)) : RGBf(to_color(cc))
    end

    # # create large square with r=1 circle sector cutout
    # # only regenerate if circle sector angle changes
    # thetadiff = map(lims -> abs(lims[2] - lims[1]), po.blockscene, po.target_thetalims, ignore_equal_values = true)
    # outer_clip = map(po.blockscene, thetadiff, po.sample_density) do diff, sample_density
    #     return _polar_clip_polygon(0, diff, sample_density)
    # end
    # outer_clip_plot = poly!(
    #     po.overlay,
    #     outer_clip,
    #     color = clipcolor,
    #     visible = po.clip,
    #     fxaa = false,
    #     transformation = Transformation(), # no polar transform for this
    #     shading = NoShading
    # )

    # # inner clip is a (filled) circle sector which also needs to regenerate with
    # # changes in thetadiff
    # inner_clip = map(po.blockscene, thetadiff, po.sample_density) do diff, sample_density
    #     pad = diff / sample_density
    #     if diff > 2pi - 2pad
    #         ps = polar2cartesian.(1.0, LinRange(0, 2pi, sample_density))
    #     else
    #         ps = polar2cartesian.(1.0, LinRange(-pad, diff + pad, sample_density))
    #         push!(ps, Point2f(0))
    #     end
    #     return Polygon(ps)
    # end
    # inner_clip_plot = poly!(
    #     po.overlay,
    #     inner_clip,
    #     color = clipcolor,
    #     visible = po.clip,
    #     fxaa = false,
    #     transformation = Transformation(),
    #     shading = NoShading
    # )

    # # handle placement with transform
    # onany(po.blockscene, po.target_thetalims, po.direction, po.target_theta_0) do thetalims, dir, theta_0
    #     thetamin, thetamax = dir .* (thetalims .+ theta_0)
    #     angle = dir > 0 ? thetamin : thetamax
    #     rotate!.((outer_clip_plot, inner_clip_plot), (Vec3f(0,0,1),), angle)
    # end

    # onany(po.blockscene, po.target_rlims, po.target_r0) do lims, r0
    #     s = (lims[1] - r0) / (lims[2] - r0)
    #     scale!(inner_clip_plot, Vec3f(s, s, 1))
    # end

    # notify(po.target_r0)   

    # tick labels
    astrokecolor = map(po.blockscene, clipcolor, po.aticklabelstrokecolor) do bg, sc
        sc === automatic ? bg : to_color(sc)
    end
    aticklabelplot = text!(
        po.overlay, atick_pos_lbl;
        fontsize = po.aticklabelsize,
        font = po.aticklabelfont,
        color = po.aticklabelcolor,
        strokewidth = po.aticklabelstrokewidth,
        strokecolor = astrokecolor,
        align = (:right, :bottom), #atick_align,
        rotation = atick_rotation,
        visible = po.aticklabelsvisible        
    )

    bstrokecolor = map(po.blockscene, clipcolor, po.bticklabelstrokecolor) do bg, sc
        sc === automatic ? bg : to_color(sc)
    end
    bticklabelplot = text!(
        po.overlay, btick_pos_lbl;
        fontsize = po.bticklabelsize,
        font = po.bticklabelfont,
        color = po.bticklabelcolor,
        strokewidth = po.bticklabelstrokewidth,
        strokecolor = bstrokecolor,
        align = (:right, :top), #btick_align,
        rotation = btick_rotation,
        visible = po.bticklabelsvisible        
    )

    cstrokecolor = map(po.blockscene, clipcolor, po.cticklabelstrokecolor) do bg, sc
        sc === automatic ? bg : to_color(sc)
    end
    cticklabelplot = text!(
        po.overlay, ctick_pos_lbl;
        fontsize = po.cticklabelsize,
        font = po.cticklabelfont,
        color = po.cticklabelcolor,
        strokewidth = po.cticklabelstrokewidth,
        strokecolor = cstrokecolor,
        align = ctick_align,
        rotation = ctick_rotation,
        visible = po.cticklabelsvisible        
    )


    #
    # # OPT: skip glyphcollection update on offset changes
    # rticklabelplot.plots[1].plots[1].offset = rtick_offset


    # thetastrokecolor = map(po.blockscene, clipcolor, po.thetaticklabelstrokecolor) do bg, sc
    #     sc === automatic ? bg : to_color(sc)
    # end

    # thetaticklabelplot = text!(
    #     po.overlay, thetatick_pos_lbl;
    #     fontsize = po.thetaticklabelsize,
    #     font = po.thetaticklabelfont,
    #     color = po.thetaticklabelcolor,
    #     strokewidth = po.thetaticklabelstrokewidth,
    #     strokecolor = thetastrokecolor,
    #     align = thetatick_align[],
    #     visible = po.thetaticklabelsvisible
    # )
    # thetaticklabelplot.plots[1].plots[1].offset = thetatick_offset

    # # Hack to deal with synchronous update problems
    # on(po.blockscene, thetatick_align) do align
    #     thetaticklabelplot.align.val = align
    #     if length(align) == length(thetatick_pos_lbl[])
    #         notify(thetaticklabelplot.align)
    #     end
    #     return
    # end

    # # updates and z order
    # notify(po.target_thetalims)

    # translate!.((outer_clip_plot, inner_clip_plot), 0, 0, 9000)
    # translate!(spineplot, 0, 0, 9001)
    # translate!.((rticklabelplot, thetaticklabelplot), 0, 0, 9002)
    # on(po.blockscene, po.gridz) do depth
    #     translate!.((rgridplot, thetagridplot, rminorgridplot, thetaminorgridplot), 0, 0, depth)
    # end
    # notify(po.gridz)

    return aticklabelplot, bticklabelplot, cticklabelplot
end

function update_state_before_display!(ax::TernaryAxis)
    reset_limits!(ax)
    return
end

delete!(ax::TernaryAxis, p::AbstractPlot) = delete!(ax.scene, p)

################################################################################
### Utilities
################################################################################

"""
    autolimits!(ax::TernaryAxis[, unlock_zoom = true])

Calling this tells the TernaryAxis to derive limits freely from the plotted data,
which allows rmin > 0 and thetalimits spanning less than a full circle. If
`unlock_zoom = true` this also unlocks zooming in r and theta direction and
allows for translations in r direction.
"""
function autolimits!(po::TernaryAxis, unlock_zoom = true)
    po.rlimits[] = (nothing, nothing)
    po.thetalimits[] = (nothing, nothing)
    if unlock_zoom
        po.fixrmin[] = false
        po.rzoomlock[] = false
        po.thetazoomlock[] = false
    end
    return
end

function tightlimits!(po::TernaryAxis)
    po.rautolimitmargin = (0, 0)
    po.thetaautolimitmargin = (0, 0)
    reset_limits!(po)
end


"""
    rlims!(ax::TernaryAxis[, rmin], rmax)

Sets the radial limits of a given `TernaryAxis`.
"""
rlims!(po::TernaryAxis, r::Union{Symbol, Nothing, Real}) = rlims!(po, po.rlimits[][1], r)

function rlims!(po::TernaryAxis, rmin::Union{Symbol, Nothing, Real}, rmax::Union{Nothing, Real})
    po.rlimits[] = (rmin, rmax)
    return
end

"""
    thetalims!(ax::TernaryAxis, thetamin, thetamax)

Sets the angular limits of a given `TernaryAxis`.
"""
function thetalims!(po::TernaryAxis, thetamin::Union{Nothing, Real}, thetamax::Union{Nothing, Real})
    po.thetalimits[] = (thetamin, thetamax)
    return
end

"""
    hiderdecorations!(ax::TernaryAxis; ticklabels = true, grid = true, minorgrid = true)

Hide decorations of the r-axis: label, ticklabels, ticks and grid. Keyword
arguments can be used to disable hiding of certain types of decorations.
"""
function hiderdecorations!(ax::TernaryAxis; ticklabels = true, grid = true, minorgrid = true)
    if ticklabels
        ax.rticklabelsvisible = false
    end
    if grid
        ax.rgridvisible = false
    end
    if minorgrid
        ax.rminorgridvisible = false
    end
end

"""
    hidethetadecorations!(ax::TernaryAxis; ticklabels = true, grid = true, minorgrid = true)

Hide decorations of the theta-axis: label, ticklabels, ticks and grid. Keyword
arguments can be used to disable hiding of certain types of decorations.
"""
function hidethetadecorations!(ax::TernaryAxis; ticklabels = true, grid = true, minorgrid = true)
    if ticklabels
        ax.thetaticklabelsvisible = false
    end
    if grid
        ax.thetagridvisible = false
    end
    if minorgrid
        ax.thetaminorgridvisible = false
    end
end

"""
    hidedecorations!(ax::TernaryAxis; ticklabels = true, grid = true, minorgrid = true)

Hide decorations of both r and theta-axis: label, ticklabels, ticks and grid.
Keyword arguments can be used to disable hiding of certain types of decorations.

See also [`hiderdecorations!`], [`hidethetadecorations!`], [`hidezdecorations!`]
"""
function hidedecorations!(ax::TernaryAxis; ticklabels = true, grid = true, minorgrid = true)
    hiderdecorations!(ax; ticklabels = ticklabels, grid = grid, minorgrid = minorgrid,)
    hidethetadecorations!(ax; ticklabels = ticklabels, grid = grid, minorgrid = minorgrid)
end

function hidespines!(ax::TernaryAxis)
    ax.spinevisible = false
end
