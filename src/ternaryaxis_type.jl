@Block TernaryAxis <: AbstractAxis begin
    scene::Scene
    overlay::Scene
    target_alims::Observable{Tuple{Float64, Float64}}
    target_blims::Observable{Tuple{Float64, Float64}}
    target_clims::Observable{Tuple{Float64, Float64}}

    # target_thetalims::Observable{Tuple{Float64, Float64}}
    # target_theta_0::Observable{Float32}
    # target_r0::Observable{Float32}
    @attributes begin
        # Generic
        """
        Global state for the x dimension conversion.
        """
        dim1_conversion = nothing
        """
        Global state for the y dimension conversion.
        """
        dim2_conversion = nothing


        "The height setting of the scene."
        height = nothing
        "The width setting of the scene."
        width = nothing
        "Controls if the parent layout can adjust to this element's width"
        tellwidth::Bool = true
        "Controls if the parent layout can adjust to this element's height"
        tellheight::Bool = true
        "The horizontal alignment of the scene in its suggested bounding box."
        halign = :center
        "The vertical alignment of the scene in its suggested bounding box."
        valign = :center
        "The alignment of the scene in its suggested bounding box."
        alignmode = Inside()

        # Background / clip settings

        "The background color of the axis."
        backgroundcolor = inherit(scene, :backgroundcolor, :white)
        "Controls whether to activate the nonlinear clip feature. Note that this should not be used when the background is ultimately transparent."
        clip::Bool = true
        "Sets the color of the clip polygon. Mainly for debug purposes."
        clipcolor = automatic

        # Limits & transformation settings

        "The limits of a on the TernaryAxis."
        alimits = (0.0, 1.0)
        "The limits of b on the TernaryAxis."
        blimits = (0.0, 1.0)
        "The limits of c on the TernaryAxis."
        climits = (0.0, 1.0)
        # "Controls whether `r < 0` (after applying `radius_at_origin`) gets clipped (true) or not (false)."
        # clip_r::Bool = true
        # "The relative margins added to the autolimits in r direction."
        # rautolimitmargin::Tuple{Float64, Float64} = (0.05, 0.05)
        # "The relative margins added to the autolimits in theta direction."
        # thetaautolimitmargin::Tuple{Float64, Float64} = (0.05, 0.05)

        # Spine
        "The width of the spine."
        spinewidth::Float32 = 2
        "The color of the spine."
        spinecolor = :black
        "Controls whether the spine is visible."
        spinevisible::Bool = true
        "The linestyle of the spine."
        spinestyle = nothing

        # a ticks
        "The specifier for the ticks on the `a` axis, similar to `xticks` for a normal Axis."
        aticks = LinearTicks(10)
        "The specifier for the minor `a` ticks."
        aminorticks = IntervalsBetween(2)
        "The formatter for the `a` ticks"
        atickformat = Makie.automatic
        "The fontsize of the `a` tick labels."
        aticklabelsize::Float32 = inherit(scene, (:Axis, :xticklabelsize), 16)
        "The font of the `a` tick labels."
        aticklabelfont = inherit(scene, (:Axis, :xticklabelfont), inherit(scene, :font, Makie.defaultfont()))
        "The color of the `a` tick labels."
        aticklabelcolor = inherit(scene, (:Axis, :xticklabelcolor), inherit(scene, :textcolor, :black))
        "The width of the outline of `a` ticks. Setting this to 0 will remove the outline."
        aticklabelstrokewidth::Float32 = 0.0
        "The color of the outline of `a` ticks. By default this uses the background color."
        aticklabelstrokecolor = automatic
        "Padding of the `a` ticks label."
        aticklabelpad::Float32 = 4f0
        "Controls if the `a` ticks are visible."
        aticklabelsvisible::Bool = inherit(scene, (:Axis, :xticklabelsvisible), true)
        """
        Sets the rotation of `a` tick labels.

        Options:
        - `:radial` rotates labels based on the angle they appear at
        - `:horizontal` keeps labels at a horizontal orientation
        - `:aligned` rotates labels based on the angle they appear at but keeps them up-right and close to horizontal
        - `automatic` uses `:horizontal` when theta limits span >1.9pi and `:aligned` otherwise
        - `::Real` sets the label rotation to a specific value
        """
        aticklabelrotation = automatic

        # b ticks
        "The specifier for the ticks on the `b` axis, similar to `xticks` for a normal Axis."
        bticks = LinearTicks(10)
        "The specifier for the minor `b` ticks."
        bminorticks = IntervalsBetween(2)
        "The formatter for the `b` ticks"
        btickformat = Makie.automatic
        "The fontsize of the `b` tick labels."
        bticklabelsize::Float32 = inherit(scene, (:Axis, :xticklabelsize), 16)
        "The font of the `b` tick labels."
        bticklabelfont = inherit(scene, (:Axis, :xticklabelfont), inherit(scene, :font, Makie.defaultfont()))
        "The color of the `b` tick labels."
        bticklabelcolor = inherit(scene, (:Axis, :xticklabelcolor), inherit(scene, :textcolor, :black))
        "The width of the outline of `b` ticks. Setting this to 0 will remove the outline."
        bticklabelstrokewidth::Float32 = 0.0
        "The color of the outline of `b` ticks. By default this uses the background color."
        bticklabelstrokecolor = automatic
        "Padding of the `b` ticks label."
        bticklabelpad::Float32 = 4f0
        "Controls if the `b` ticks are visible."
        bticklabelsvisible::Bool = inherit(scene, (:Axis, :xticklabelsvisible), true)
        """
        Sets the rotation of `b` tick labels.

        Options:
        - `:radial` rotates labels based on the angle they appear at
        - `:horizontal` keeps labels at a horizontal orientation
        - `:aligned` rotates labels based on the angle they appear at but keeps them up-right and close to horizontal
        - `automatic` uses `:horizontal` when theta limits span >1.9pi and `:aligned` otherwise
        - `::Real` sets the label rotation to a specific value
        """
        bticklabelrotation = automatic

        # c ticks
        "The specifier for the ticks on the `c` axis, similar to `xticks` for a normal Axis."
        cticks = LinearTicks(10)
        "The specifier for the minor `c` ticks."
        cminorticks = IntervalsBetween(2)
        "The formatter for the `c` ticks"
        ctickformat = Makie.automatic
        "The fontsize of the `c` tick labels."
        cticklabelsize::Float32 = inherit(scene, (:Axis, :xticklabelsize), 16)
        "The font of the `c` tick labels."
        cticklabelfont = inherit(scene, (:Axis, :xticklabelfont), inherit(scene, :font, Makie.defaultfont()))
        "The color of the `c` tick labels."
        cticklabelcolor = inherit(scene, (:Axis, :xticklabelcolor), inherit(scene, :textcolor, :black))
        "The width of the outline of `c` ticks. Setting this to 0 will remove the outline."
        cticklabelstrokewidth::Float32 = 0.0
        "The color of the outline of `c` ticks. By default this uses the background color."
        cticklabelstrokecolor = automatic
        "Padding of the `c` ticks label."
        cticklabelpad::Float32 = 4f0
        "Controls if the `c` ticks are visible."
        cticklabelsvisible::Bool = inherit(scene, (:Axis, :xticklabelsvisible), true)
        """
        Sets the rotation of `c` tick labels.

        Options:
        - `:radial` rotates labels based on the angle they appear at
        - `:horizontal` keeps labels at a horizontal orientation
        - `:aligned` rotates labels based on the angle they appear at but keeps them up-right and close to horizontal
        - `automatic` uses `:horizontal` when theta limits span >1.9pi and `:aligned` otherwise
        - `::Real` sets the label rotation to a specific value
        """
        cticklabelrotation = automatic

        # a minor and major grid
        "Sets the z value of the `a` grid lines. To place the grid above plots set this to a value between 1 and 8999."
        agridz::Float32 = -100

        "The color of the `a` grid."
        agridcolor = inherit(scene, (:Axis, :xgridcolor), (:black, 0.5))
        "The linewidth of the `a` grid."
        agridwidth::Float32 = inherit(scene, (:Axis, :xgridwidth), 1)
        "The linestyle of the `a` grid."
        agridstyle = inherit(scene, (:Axis, :xgridstyle), nothing)
        "Controls if the `a` grid is visible."
        agridvisible::Bool = inherit(scene, (:Axis, :xgridvisible), true)

        "The color of the `a` minor grid."
        aminorgridcolor = inherit(scene, (:Axis, :xminorgridcolor), (:black, 0.2))
        "The linewidth of the `a` minor grid."
        aminorgridwidth::Float32 = inherit(scene, (:Axis, :xminorgridwidth), 1)
        "The linestyle of the `a` minor grid."
        aminorgridstyle = inherit(scene, (:Axis, :xminorgridstyle), nothing)
        "Controls if the `a` minor grid is visible."
        aminorgridvisible::Bool = inherit(scene, (:Axis, :xminorgridvisible), false)

        # b minor and major grid
        "Sets the z value of `b` grid lines. To place the grid above plots set this to a value between 1 and 8999."
        bgridz::Float32 = -100

        "The color of the `b` grid."
        bgridcolor = inherit(scene, (:Axis, :xgridcolor), (:black, 0.5))
        "The linewidth of the `b` grid."
        bgridwidth::Float32 = inherit(scene, (:Axis, :xgridwidth), 1)
        "The linestyle of the `b` grid."
        bgridstyle = inherit(scene, (:Axis, :xgridstyle), nothing)
        "Controls if the `b` grid is visible."
        bgridvisible::Bool = inherit(scene, (:Axis, :xgridvisible), true)

        "The color of the `b` minor grid."
        bminorgridcolor = inherit(scene, (:Axis, :xminorgridcolor), (:black, 0.2))
        "The linewidth of the `b` minor grid."
        bminorgridwidth::Float32 = inherit(scene, (:Axis, :xminorgridwidth), 1)
        "The linestyle of the `b` minor grid."
        bminorgridstyle = inherit(scene, (:Axis, :xminorgridstyle), nothing)
        "Controls if the `b` minor grid is visible."
        bminorgridvisible::Bool = inherit(scene, (:Axis, :xminorgridvisible), false)

        
        # c minor and major grid
        "Sets the z value of `b` grid lines. To place the grid above plots set this to a value between 1 and 8999."
        cgridz::Float32 = -100

        "The color of the `b` grid."
        cgridcolor = inherit(scene, (:Axis, :xgridcolor), (:black, 0.5))
        "The linewidth of the `b` grid."
        cgridwidth::Float32 = inherit(scene, (:Axis, :xgridwidth), 1)
        "The linestyle of the `b` grid."
        cgridstyle = inherit(scene, (:Axis, :xgridstyle), nothing)
        "Controls if the `b` grid is visible."
        cgridvisible::Bool = inherit(scene, (:Axis, :xgridvisible), true)

        "The color of the `b` minor grid."
        cminorgridcolor = inherit(scene, (:Axis, :xminorgridcolor), (:black, 0.2))
        "The linewidth of the `b` minor grid."
        cminorgridwidth::Float32 = inherit(scene, (:Axis, :xminorgridwidth), 1)
        "The linestyle of the `b` minor grid."
        cminorgridstyle = inherit(scene, (:Axis, :xminorgridstyle), nothing)
        "Controls if the `b` minor grid is visible."
        cminorgridvisible::Bool = inherit(scene, (:Axis, :xminorgridvisible), false)

        # Title
        "The title of the plot"
        title = ""
        "The gap between the title and the top of the axis"
        titlegap::Float32 = inherit(scene, (:Axis, :titlesize), map(x -> x / 2, inherit(scene, :fontsize, 16)))
        "The alignment of the title.  Can be any of `:center`, `:left`, or `:right`."
        titlealign = :center
        "The fontsize of the title."
        titlesize::Float32 = inherit(scene, (:Axis, :titlesize), map(x -> 1.2x, inherit(scene, :fontsize, 16)))
        "The font of the title."
        titlefont = inherit(scene, (:Axis, :titlefont), inherit(scene, :font, Makie.defaultfont()))
        "The color of the title."
        titlecolor = inherit(scene, (:Axis, :titlecolor), inherit(scene, :textcolor, :black))
        "Controls if the title is visible."
        titlevisible::Bool = inherit(scene, (:Axis, :titlevisible), true)

        # Interactive Controls

        "Sets the speed of scroll based zooming. Setting this to 0 effectively disables zooming."
        zoomspeed::Float32 = 0.01
        "Sets the key used to decide the zoom direction when zooming. If pressed, the upper axis limit on the respective axis will be moved to zoom."
        zoomdirectionkey = Keyboard.left_shift
        "Sets the key used to activate zooming in a-direction. Can be set to `true` to always restrict zooming or `false` to disable the interaction."
        azoomkey = Keyboard.a
        "Sets the key used to activate zooming in a-direction. Can be set to `true` to always restrict zooming or `false` to disable the interaction."
        bzoomkey = Keyboard.b
        "Sets the key used to activate zooming in a-direction. Can be set to `true` to always restrict zooming or `false` to disable the interaction."
        czoomkey = Keyboard.c
        # "Sets the key used to restrict zooming to the theta-direction. Can be set to `true` to always restrict zooming or `false` to disable the interaction."
        # thetazoomkey = Keyboard.t
        # "Controls whether rmin remains fixed during zooming and translation. (The latter will be turned off by setting this to true.)"
        # fixrmin::Bool = true
        # "Controls whether adjusting the rlimits through interactive zooming is blocked."
        # rzoomlock::Bool = false
        # "Controls whether adjusting the thetalimits through interactive zooming is blocked."
        # thetazoomlock::Bool = true
        # "Sets the mouse button for translating the plot in r-direction."
        # r_translation_button = Mouse.right
        # "Sets the mouse button for translating the plot in theta-direction. Note that this can be the same as `radial_translation_button`."
        # theta_translation_button = Mouse.right
        # "Sets the button for rotating the TernaryAxis as a whole. This replaces theta translation when triggered and must include a mouse button."
        # axis_rotation_button = Keyboard.left_control & Mouse.right
        # "Sets the button or button combination for resetting the axis view. (This should be compatible with `ispressed`.)"
        # reset_button = Keyboard.left_control & Mouse.left
        # "Sets whether the axis orientation (changed with the axis_rotation_button) gets reset when resetting the axis. If set to false only the limits will reset."
        # reset_axis_orientation::Bool = false
    end
end
