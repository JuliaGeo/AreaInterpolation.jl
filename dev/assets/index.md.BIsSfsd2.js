import{_ as e,c as t,o as a,a6 as i}from"./chunks/framework._RWIvzqw.js";const g=JSON.parse('{"title":"AreaInterpolation","description":"","frontmatter":{},"headers":[],"relativePath":"index.md","filePath":"index.md","lastUpdated":null}'),o={name:"index.md"},r=i('<h1 id="AreaInterpolation" tabindex="-1">AreaInterpolation <a class="header-anchor" href="#AreaInterpolation" aria-label="Permalink to &quot;AreaInterpolation {#AreaInterpolation}&quot;">​</a></h1><p>Documentation for <a href="https://github.com/JuliaGeo/AreaInterpolation.jl" target="_blank" rel="noreferrer">AreaInterpolation</a>.</p><ul><li><a href="#AreaInterpolation.AbstractInterpolationMethod"><code>AreaInterpolation.AbstractInterpolationMethod</code></a></li><li><a href="#AreaInterpolation.Dasymetric"><code>AreaInterpolation.Dasymetric</code></a></li><li><a href="#AreaInterpolation.Direct"><code>AreaInterpolation.Direct</code></a></li><li><a href="#AreaInterpolation.Pycnophylactic"><code>AreaInterpolation.Pycnophylactic</code></a></li><li><a href="#AreaInterpolation.decompose_to_geoms_and_values-Tuple{Any}"><code>AreaInterpolation.decompose_to_geoms_and_values</code></a></li><li><a href="#AreaInterpolation.nan_aware_kernelproduct-Union{Tuple{L}, Tuple{Stencils.Stencil{&lt;:Any, &lt;:Any, L}, Any}} where L"><code>AreaInterpolation.nan_aware_kernelproduct</code></a></li><li><a href="#AreaInterpolation.pycno_iteration!-NTuple{6, Any}"><code>AreaInterpolation.pycno_iteration!</code></a></li></ul><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="AreaInterpolation.AbstractInterpolationMethod" href="#AreaInterpolation.AbstractInterpolationMethod">#</a> <b><u>AreaInterpolation.AbstractInterpolationMethod</u></b> — <i>Type</i>. <div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">abstract type</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> AbstractInterpolationMethod</span></span></code></pre></div><p>The abstract type for all areal interpolation methods.</p><p><strong>Interface</strong></p><p>All <code>AbstractArealInterpolator</code>s must implement the following interface:</p><ul><li><code>interpolate(interpolator::AbstractInterpolationMethod, target::GI.AbstractPolygon, sources, values::Vector{Vector}, source_rtree)</code></li></ul><p>This interface is not set in stone and can be changed!</p><p>TODOS: - extensive vs intensive variables (currently we act as though variables are intensive) - weight methods (sum vs total) - just pass any arbitrary accumulator</p><p><a href="https://github.com/JuliaGeo/AreaInterpolation.jl/blob/b0009bba6ffd820972f9523b62cec2edfc2805e6/src/types.jl#L3-L16" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="AreaInterpolation.Dasymetric" href="#AreaInterpolation.Dasymetric">#</a> <b><u>AreaInterpolation.Dasymetric</u></b> — <i>Type</i>. <div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Dasymetric</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(mask</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Raster</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><p>Dasymetric interpolation uses a mask to weight the influence of each polygon.</p><p>Depending on the choice of mask, like land-use data, this can prove to be a more accurate interpolation than the direct or pycnophylactic methods.</p><p><a href="https://github.com/JuliaGeo/AreaInterpolation.jl/blob/b0009bba6ffd820972f9523b62cec2edfc2805e6/src/types.jl#L128-L135" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="AreaInterpolation.Direct" href="#AreaInterpolation.Direct">#</a> <b><u>AreaInterpolation.Direct</u></b> — <i>Type</i>. <div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Direct</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">()</span></span></code></pre></div><p>A simple direct method for areal interpolation.</p><p>Takes the area-weighted mean of all source polygons&#39; features, weighted by their areas of intersection with the target polygon.</p><p>This method does not allocate a Raster, but it does perform polygon intersection tests.</p><p><a href="https://github.com/JuliaGeo/AreaInterpolation.jl/blob/b0009bba6ffd820972f9523b62cec2edfc2805e6/src/types.jl#L68-L77" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="AreaInterpolation.Pycnophylactic" href="#AreaInterpolation.Pycnophylactic">#</a> <b><u>AreaInterpolation.Pycnophylactic</u></b> — <i>Type</i>. <div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Pycnophylactic</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(cellsize; relaxation, maxiters, tol)</span></span></code></pre></div><p>A pycnophylactic method for areal interpolation.</p><p>Pycnophylactic interpolation (Tobler, 1979) interpolates the source zone attribute to the target zones in a way that avoids sharp discontinuities between neighbouring target zones. It assumes that no sharp boundaries exist in the distribution of the allocated data, which may not be the case, for example, when target zones are divided by linear features (rivers, railways, roads) or are adjacent to waterbodies.</p><p>However, it generates intuitively elegant allocations for many urban case studies with many applications (Kounadi, Ristea, Leitner, &amp; Langford, 2018; Comber, Proctor, &amp; Anthony, 2008).</p><p>This description was taken in part from <a href="https://gistbok.ucgis.org/bok-topics/areal-interpolation" target="_blank" rel="noreferrer">the GIS&amp;T Body of Knowledge</a>.</p><p><strong>Fields</strong></p><ul><li><p><code>cellsize</code>: The cell size of the raster to be interpolated, in units of the CRS of the input polygons (can be degrees or meters). <strong>Required argument!</strong></p></li><li><p><code>kernel</code>: The kernel with which to smooth the raster. Defaults to a 2-D Moore window of size 1, with value 0.5.</p></li><li><p><code>relaxation</code>: The relaxation factor. Defaults to <code>0.2</code>.</p></li><li><p><code>maxiters</code>: The maximum number of iterations. Defaults to <code>300</code>.</p></li><li><p><code>tol</code>: The error tolerance at which convergence is achieved. Defaults to <code>10e-3</code>.</p></li></ul><p><strong>Differences from other implementations</strong></p><p><code>tobler</code> in Python uses the equivalent of <code>Stencils.Kernel(Stencils.Cross(1, 2), [0.5, 0.5, 0, 0.5, 0.5])</code>. This implementation allows arbitrary kernels, so the user can choose the kind of smoothing and kernel window based on their desires.</p><p><a href="https://github.com/JuliaGeo/AreaInterpolation.jl/blob/b0009bba6ffd820972f9523b62cec2edfc2805e6/src/types.jl#L80-L105" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="AreaInterpolation.decompose_to_geoms_and_values-Tuple{Any}" href="#AreaInterpolation.decompose_to_geoms_and_values-Tuple{Any}">#</a> <b><u>AreaInterpolation.decompose_to_geoms_and_values</u></b> — <i>Method</i>. <div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">decompose_to_geoms_and_values</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(sources; features </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> nothing</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><p>Decompose a table or feature collection into geometries and values. Returns <code>(geometries::Vector{Geometry}, values::NamedTuple{Vector})</code>.</p><p><code>values</code> is a namedtuple of each value column in <code>sources</code>. A value column is something whose eltype satisfies <code>isvaluecol</code>, and is currently <code>Union{Number, Missing}</code>.</p><p><a href="https://github.com/JuliaGeo/AreaInterpolation.jl/blob/b0009bba6ffd820972f9523b62cec2edfc2805e6/src/utils.jl#L5-L13" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="AreaInterpolation.nan_aware_kernelproduct-Union{Tuple{L}, Tuple{Stencils.Stencil{&lt;:Any, &lt;:Any, L}, Any}} where L" href="#AreaInterpolation.nan_aware_kernelproduct-Union{Tuple{L}, Tuple{Stencils.Stencil{&lt;:Any, &lt;:Any, L}, Any}} where L">#</a> <b><u>AreaInterpolation.nan_aware_kernelproduct</u></b> — <i>Method</i>. <div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">nan_aware_kernelproduct</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(hood</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Stencils.Stencil{&lt;:Any,&lt;:Any,L}</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, kernel) </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">where</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> L</span></span></code></pre></div><p>Compute the dot product of the kernel and the stencil, ignoring NaN values. This function is the equivalent of <code>Stencils.kernelproduct</code>.</p><p><a href="https://github.com/JuliaGeo/AreaInterpolation.jl/blob/b0009bba6ffd820972f9523b62cec2edfc2805e6/src/pycnophylactic.jl#L127-L132" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="AreaInterpolation.pycno_iteration!-NTuple{6, Any}" href="#AreaInterpolation.pycno_iteration!-NTuple{6, Any}">#</a> <b><u>AreaInterpolation.pycno_iteration!</u></b> — <i>Method</i>. <div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">pycno_iteration!</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(old, new, sa, polygon_views, vals, relaxation)</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Float64</span></span></code></pre></div><p>Perform a single iteration of the pycnophylactic algorithm, and overwrites the values in <code>new</code> and <code>old</code> with the result. Returns the absolute maximum change in the data.</p><p><strong>Steps</strong></p><ol><li><p>Convolve the stencil in <code>sa</code> with <code>old</code> (stored in <code>sa</code> as well).</p></li><li><p>Apply the relaxation term to <code>new</code> and <code>old</code>.</p></li><li><p>Apply the area based correction to <code>new</code>.</p></li><li><p>Reset any negative values to 0.</p></li><li><p>Apply the mass preserving correction to <code>new</code>.</p></li><li><p>Find the maximum change in the data.</p></li><li><p>Overwrite the old data with the new data.</p></li></ol><p><a href="https://github.com/JuliaGeo/AreaInterpolation.jl/blob/b0009bba6ffd820972f9523b62cec2edfc2805e6/src/pycnophylactic.jl#L21-L37" target="_blank" rel="noreferrer">source</a></p></div><br>',17),n=[r];function s(l,p,c,d,h,u){return a(),t("div",null,n)}const y=e(o,[["render",s]]);export{g as __pageData,y as default};
