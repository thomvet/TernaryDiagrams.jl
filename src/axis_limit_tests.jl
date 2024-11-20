using TernaryDiagrams, GLMakie

f = Figure(size = (1200, 1000))

#cut just the a axis
ax1 = TernaryAxis(f[1, 1], title = "Title", agridcolor = :blue, bgridcolor = :green, cgridcolor = :red, aticklabelcolor = :blue, bticklabelcolor = :green, cticklabelcolor = :red)
ax1.alimits = (0.2, 0.6)
ax1.aticks = 0:0.1:1.0

#cut just the b axis
ax2 = TernaryAxis(f[1, 2], title = "Title", agridcolor = :blue, bgridcolor = :green, cgridcolor = :red, aticklabelcolor = :blue, bticklabelcolor = :green, cticklabelcolor = :red)
ax2.blimits = (0.1, 0.8)
ax2.bticks = 0:0.1:1.0

#cut just the c axis
ax3 = TernaryAxis(f[1, 3], title = "Title", agridcolor = :blue, bgridcolor = :green, cgridcolor = :red, aticklabelcolor = :blue, bticklabelcolor = :green, cticklabelcolor = :red)
ax3.climits = (0.3, 0.7)
ax3.cticks = 0:0.1:1.0

#cut a and b axis
ax4 = TernaryAxis(f[2, 1], title = "Title", agridcolor = :blue, bgridcolor = :green, cgridcolor = :red, aticklabelcolor = :blue, bticklabelcolor = :green, cticklabelcolor = :red)
ax4.alimits = (0.1, 0.9)
ax4.aticks = 0:0.1:1.0
ax4.blimits = (0.2, 0.8)
ax4.bticks = 0:0.1:1.0

#cut a and c axis
ax5 = TernaryAxis(f[2, 2], title = "Title", agridcolor = :blue, bgridcolor = :green, cgridcolor = :red, aticklabelcolor = :blue, bticklabelcolor = :green, cticklabelcolor = :red)
ax5.alimits = (0.2, 0.9)
ax5.aticks = 0:0.1:1.0
ax5.climits = (0.3, 0.7)
ax5.cticks = 0:0.1:1.0

#cut b and c axis
ax6 = TernaryAxis(f[2, 3], title = "Title", agridcolor = :blue, bgridcolor = :green, cgridcolor = :red, aticklabelcolor = :blue, bticklabelcolor = :green, cticklabelcolor = :red)
ax6.blimits = (0.4, 0.6)
ax6.bticks = 0:0.1:1.0
ax6.climits = (0.1, 0.9)
ax6.cticks = 0:0.1:1.0

f = Figure(size = (1200, 1000))
#cut just the a axis
ax7 = TernaryAxis(f[1, 1], title = "Title", agridcolor = :blue, bgridcolor = :green, cgridcolor = :red, aticklabelcolor = :blue, bticklabelcolor = :green, cticklabelcolor = :red)
ax7.alimits = (0.2, 0.6)
ax7.blimits = (0.0, 0.5)
ax7.climits = (0.0, 0.75)
ax7.aticks = 0:0.05:1.0
ax7.bticks = 0:0.05:1.0
ax7.cticks = 0:0.05:1.0