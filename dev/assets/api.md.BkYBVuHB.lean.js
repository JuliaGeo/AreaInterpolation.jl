import{_ as n,c as l,a5 as a,j as t,a as s,G as o,B as r,o as p}from"./chunks/framework.CRgaxpTU.js";const F=JSON.parse('{"title":"","description":"","frontmatter":{},"headers":[],"relativePath":"api.md","filePath":"api.md","lastUpdated":null}'),c={name:"api.md"},d={class:"jldocstring custom-block",open:""},h={class:"jldocstring custom-block",open:""},u={class:"jldocstring custom-block",open:""},y={class:"jldocstring custom-block",open:""},g={class:"jldocstring custom-block",open:""},k={class:"jldocstring custom-block",open:""},b={class:"jldocstring custom-block",open:""},m={class:"jldocstring custom-block",open:""},f={class:"jldocstring custom-block",open:""},A={class:"jldocstring custom-block",open:""};function v(j,e,I,E,C,w){const i=r("Badge");return p(),l("div",null,[e[30]||(e[30]=a('<h2 id="API-reference" tabindex="-1">API reference <a class="header-anchor" href="#API-reference" aria-label="Permalink to &quot;API reference {#API-reference}&quot;">​</a></h2><ul><li><a href="#AreaInterpolation.AbstractInterpolationMethod"><code>AreaInterpolation.AbstractInterpolationMethod</code></a></li><li><a href="#AreaInterpolation.Dasymetric"><code>AreaInterpolation.Dasymetric</code></a></li><li><a href="#AreaInterpolation.Direct"><code>AreaInterpolation.Direct</code></a></li><li><a href="#AreaInterpolation.Pycno"><code>AreaInterpolation.Pycno</code></a></li><li><a href="#AreaInterpolation.Pycnophylactic"><code>AreaInterpolation.Pycnophylactic</code></a></li><li><a href="#AreaInterpolation.decompose_to_geoms_and_values-Tuple{Any}"><code>AreaInterpolation.decompose_to_geoms_and_values</code></a></li><li><a href="#AreaInterpolation.nan_aware_kernelproduct-Union{Tuple{L}, Tuple{Stencils.Stencil{&lt;:Any, &lt;:Any, L}, Any}} where L"><code>AreaInterpolation.nan_aware_kernelproduct</code></a></li><li><a href="#AreaInterpolation.pycno_iteration!-NTuple{6, Any}"><code>AreaInterpolation.pycno_iteration!</code></a></li><li><a href="#AreaInterpolation.pycno_raster-Tuple{Pycnophylactic, Any, Any}"><code>AreaInterpolation.pycno_raster</code></a></li><li><a href="#AreaInterpolation.rasterized_polygon_areas-Tuple{Any, Any}"><code>AreaInterpolation.rasterized_polygon_areas</code></a></li></ul>',2)),t("details",d,[t("summary",null,[e[0]||(e[0]=t("a",{id:"AreaInterpolation.AbstractInterpolationMethod",href:"#AreaInterpolation.AbstractInterpolationMethod"},[t("span",{class:"jlbinding"},"AreaInterpolation.AbstractInterpolationMethod")],-1)),e[1]||(e[1]=s()),o(i,{type:"info",class:"jlObjectType jlType",text:"Type"})]),e[2]||(e[2]=a('<div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">abstract type</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> AbstractInterpolationMethod</span></span></code></pre></div><p>The abstract type for all areal interpolation methods.</p><p><strong>Interface</strong></p><p>All <code>AbstractArealInterpolator</code>s must implement the following interface:</p><ul><li><code>interpolate(interpolator::AbstractInterpolationMethod, target::GI.AbstractPolygon, sources, values::Vector{Vector}, source_rtree)</code></li></ul><p>This interface is not set in stone and can be changed!</p><p>TODOS: - extensive vs intensive variables (currently we act as though variables are intensive) - weight methods (sum vs total) - just pass any arbitrary accumulator</p><p><a href="https://github.com/JuliaGeo/AreaInterpolation.jl/blob/4fb51b43f14cc74534aeb3c05e9d7c35c737ba2a/src/types.jl#L6-L19" target="_blank" rel="noreferrer">source</a></p>',8))]),t("details",h,[t("summary",null,[e[3]||(e[3]=t("a",{id:"AreaInterpolation.Dasymetric",href:"#AreaInterpolation.Dasymetric"},[t("span",{class:"jlbinding"},"AreaInterpolation.Dasymetric")],-1)),e[4]||(e[4]=s()),o(i,{type:"info",class:"jlObjectType jlType",text:"Type"})]),e[5]||(e[5]=a('<div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Dasymetric</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(mask</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Raster</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><p>Dasymetric interpolation uses a mask to weight the influence of each polygon.</p><p>Depending on the choice of mask, like land-use data, this can prove to be a more accurate interpolation than the direct or pycnophylactic methods.</p><p><a href="https://github.com/JuliaGeo/AreaInterpolation.jl/blob/4fb51b43f14cc74534aeb3c05e9d7c35c737ba2a/src/types.jl#L91-L98" target="_blank" rel="noreferrer">source</a></p>',4))]),t("details",u,[t("summary",null,[e[6]||(e[6]=t("a",{id:"AreaInterpolation.Direct",href:"#AreaInterpolation.Direct"},[t("span",{class:"jlbinding"},"AreaInterpolation.Direct")],-1)),e[7]||(e[7]=s()),o(i,{type:"info",class:"jlObjectType jlType",text:"Type"})]),e[8]||(e[8]=a('<div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Direct</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">()</span></span></code></pre></div><p>A simple direct method for areal interpolation.</p><p>Takes the area-weighted mean of all source polygons&#39; features, weighted by their areas of intersection with the target polygon.</p><p>This method does not allocate a Raster, but it does perform polygon intersection tests.</p><p><a href="https://github.com/JuliaGeo/AreaInterpolation.jl/blob/4fb51b43f14cc74534aeb3c05e9d7c35c737ba2a/src/types.jl#L25-L34" target="_blank" rel="noreferrer">source</a></p>',5))]),t("details",y,[t("summary",null,[e[9]||(e[9]=t("a",{id:"AreaInterpolation.Pycno",href:"#AreaInterpolation.Pycno"},[t("span",{class:"jlbinding"},"AreaInterpolation.Pycno")],-1)),e[10]||(e[10]=s()),o(i,{type:"info",class:"jlObjectType jlType",text:"Type"})]),e[11]||(e[11]=a('<div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Pycno</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">...</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><p>Alias for <a href="/AreaInterpolation.jl/dev/api#AreaInterpolation.Pycnophylactic"><code>Pycnophylactic</code></a>.</p><p><a href="https://github.com/JuliaGeo/AreaInterpolation.jl/blob/4fb51b43f14cc74534aeb3c05e9d7c35c737ba2a/src/types.jl#L83-L87" target="_blank" rel="noreferrer">source</a></p>',3))]),t("details",g,[t("summary",null,[e[12]||(e[12]=t("a",{id:"AreaInterpolation.Pycnophylactic",href:"#AreaInterpolation.Pycnophylactic"},[t("span",{class:"jlbinding"},"AreaInterpolation.Pycnophylactic")],-1)),e[13]||(e[13]=s()),o(i,{type:"info",class:"jlObjectType jlType",text:"Type"})]),e[14]||(e[14]=a('<div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Pycnophylactic</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(cellsize; relaxation, maxiters, tol)</span></span></code></pre></div><p>A pycnophylactic method for areal interpolation.</p><p>Pycnophylactic interpolation (Tobler, 1979) interpolates the source zone attribute to the target zones in a way that avoids sharp discontinuities between neighbouring target zones. It assumes that no sharp boundaries exist in the distribution of the allocated data, which may not be the case, for example, when target zones are divided by linear features (rivers, railways, roads) or are adjacent to waterbodies.</p><p>However, it generates intuitively elegant allocations for many urban case studies with many applications (Kounadi, Ristea, Leitner, &amp; Langford, 2018; Comber, Proctor, &amp; Anthony, 2008).</p><p>This description was taken in part from <a href="https://gistbok.ucgis.org/bok-topics/areal-interpolation" target="_blank" rel="noreferrer">the GIS&amp;T Body of Knowledge</a>.</p><p><strong>Fields</strong></p><ul><li><p><code>cellsize</code>: The cell size of the raster to be interpolated, in units of the CRS of the input polygons (can be degrees or meters). <strong>Required argument!</strong></p></li><li><p><code>kernel</code>: The kernel with which to smooth the raster. Defaults to a 2-D Moore window of size 1, with value 0.5.</p></li><li><p><code>relaxation</code>: The relaxation factor. Defaults to <code>0.2</code>.</p></li><li><p><code>maxiters</code>: The maximum number of iterations. Defaults to <code>300</code>.</p></li><li><p><code>tol</code>: The error tolerance at which convergence is achieved. Defaults to <code>10e-3</code>.</p></li></ul><p><strong>Differences from other implementations</strong></p><p><code>tobler</code> in Python uses the equivalent of <code>Stencils.Kernel(Stencils.Cross(1, 2), [0.25, 0.25, 0, 0.25, 0.25])</code>. This implementation allows arbitrary kernels, so the user can choose the kind of smoothing and kernel window based on their desires.</p><p><a href="https://github.com/JuliaGeo/AreaInterpolation.jl/blob/4fb51b43f14cc74534aeb3c05e9d7c35c737ba2a/src/types.jl#L37-L62" target="_blank" rel="noreferrer">source</a></p>',10))]),t("details",k,[t("summary",null,[e[15]||(e[15]=t("a",{id:"AreaInterpolation.decompose_to_geoms_and_values-Tuple{Any}",href:"#AreaInterpolation.decompose_to_geoms_and_values-Tuple{Any}"},[t("span",{class:"jlbinding"},"AreaInterpolation.decompose_to_geoms_and_values")],-1)),e[16]||(e[16]=s()),o(i,{type:"info",class:"jlObjectType jlMethod",text:"Method"})]),e[17]||(e[17]=a('<div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">decompose_to_geoms_and_values</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(sources; features </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> nothing</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><p>Decompose a table or feature collection into geometries and values. Returns <code>(geometries::Vector{Geometry}, values::NamedTuple{Vector})</code>.</p><p><code>values</code> is a namedtuple of each value column in <code>sources</code>. A value column is something whose eltype satisfies <code>isvaluecol</code>, and is currently <code>Union{Number, Missing}</code>.</p><p><a href="https://github.com/JuliaGeo/AreaInterpolation.jl/blob/4fb51b43f14cc74534aeb3c05e9d7c35c737ba2a/src/utils.jl#L5-L13" target="_blank" rel="noreferrer">source</a></p>',4))]),t("details",b,[t("summary",null,[e[18]||(e[18]=t("a",{id:"AreaInterpolation.nan_aware_kernelproduct-Union{Tuple{L}, Tuple{Stencils.Stencil{<:Any, <:Any, L}, Any}} where L",href:"#AreaInterpolation.nan_aware_kernelproduct-Union{Tuple{L}, Tuple{Stencils.Stencil{<:Any, <:Any, L}, Any}} where L"},[t("span",{class:"jlbinding"},"AreaInterpolation.nan_aware_kernelproduct")],-1)),e[19]||(e[19]=s()),o(i,{type:"info",class:"jlObjectType jlMethod",text:"Method"})]),e[20]||(e[20]=a('<div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">nan_aware_kernelproduct</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(hood</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Stencils.Stencil{&lt;:Any,&lt;:Any,L}</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, kernel) </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">where</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> L</span></span></code></pre></div><p>Compute the dot product of the kernel and the stencil, ignoring NaN values. This function is the equivalent of <code>Stencils.kernelproduct</code>.</p><p><a href="https://github.com/JuliaGeo/AreaInterpolation.jl/blob/4fb51b43f14cc74534aeb3c05e9d7c35c737ba2a/src/methods/pycnophylactic.jl#L148-L153" target="_blank" rel="noreferrer">source</a></p>',3))]),t("details",m,[t("summary",null,[e[21]||(e[21]=t("a",{id:"AreaInterpolation.pycno_iteration!-NTuple{6, Any}",href:"#AreaInterpolation.pycno_iteration!-NTuple{6, Any}"},[t("span",{class:"jlbinding"},"AreaInterpolation.pycno_iteration!")],-1)),e[22]||(e[22]=s()),o(i,{type:"info",class:"jlObjectType jlMethod",text:"Method"})]),e[23]||(e[23]=a('<div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">pycno_iteration!</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(old, new, sa, polygon_views, vals, relaxation)</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Float64</span></span></code></pre></div><p>Perform a single iteration of the pycnophylactic algorithm, and overwrites the values in <code>new</code> and <code>old</code> with the result. Returns the absolute maximum change in the data.</p><p><strong>Steps</strong></p><ol><li><p>Convolve the stencil in <code>sa</code> with <code>old</code> (stored in <code>sa</code> as well).</p></li><li><p>Apply the relaxation term to <code>new</code> and <code>old</code>.</p></li><li><p>Apply the area based correction to <code>new</code>.</p></li><li><p>Reset any negative values to 0.</p></li><li><p>Apply the mass preserving correction to <code>new</code>.</p></li><li><p>Find the maximum change in the data.</p></li><li><p>Overwrite the old data with the new data.</p></li></ol><p>Note that the kernel in <code>sa</code> <strong>must</strong> be normalized in the 1-norm. Additionally, the kernel is slightly different than the regular finite difference kernel - the center or self element is added separately, and therefore must be 0 in the kernel weight. Instead of a window, one might pass a Moore neighbourhood (which excludes the center).</p><p><a href="https://github.com/JuliaGeo/AreaInterpolation.jl/blob/4fb51b43f14cc74534aeb3c05e9d7c35c737ba2a/src/methods/pycnophylactic.jl#L23-L45" target="_blank" rel="noreferrer">source</a></p>',6))]),t("details",f,[t("summary",null,[e[24]||(e[24]=t("a",{id:"AreaInterpolation.pycno_raster-Tuple{Pycnophylactic, Any, Any}",href:"#AreaInterpolation.pycno_raster-Tuple{Pycnophylactic, Any, Any}"},[t("span",{class:"jlbinding"},"AreaInterpolation.pycno_raster")],-1)),e[25]||(e[25]=s()),o(i,{type:"info",class:"jlObjectType jlMethod",text:"Method"})]),e[26]||(e[26]=a('<div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">pycno_raster</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(pycno</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Pycnophylactic</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, source_geometries, vals; extensive </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> false</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Raster</span></span></code></pre></div><p>Perform pycnophylactic interpolation on <code>source_geometries</code>, using <code>vals</code> as the values. If <code>extensive</code> is <code>true</code>, then <code>vals</code> are the extensive values, and the area-adjusted values are computed for the intensive ones. Otherwise, <code>vals</code> are the intensive values, and the area-adjusted values are computed for the extensive ones.</p><p><a href="https://github.com/JuliaGeo/AreaInterpolation.jl/blob/4fb51b43f14cc74534aeb3c05e9d7c35c737ba2a/src/methods/pycnophylactic.jl#L242-L249" target="_blank" rel="noreferrer">source</a></p>',3))]),t("details",A,[t("summary",null,[e[27]||(e[27]=t("a",{id:"AreaInterpolation.rasterized_polygon_areas-Tuple{Any, Any}",href:"#AreaInterpolation.rasterized_polygon_areas-Tuple{Any, Any}"},[t("span",{class:"jlbinding"},"AreaInterpolation.rasterized_polygon_areas")],-1)),e[28]||(e[28]=s()),o(i,{type:"info",class:"jlObjectType jlMethod",text:"Method"})]),e[29]||(e[29]=a('<div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">rasterized_polygon_areas</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(source_geometries, cellsize</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Real</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Vector{Float64}</span></span></code></pre></div><p>Compute the rasterized area of each polygon in <code>source_geometries</code>, on a Raster with resolution <code>cellsize</code>. <code>sour</code></p><p>Returns a vector of cell counts per source geometry.</p><p><a href="https://github.com/JuliaGeo/AreaInterpolation.jl/blob/4fb51b43f14cc74534aeb3c05e9d7c35c737ba2a/src/utils.jl#L29-L36" target="_blank" rel="noreferrer">source</a></p>',4))])])}const _=n(c,[["render",v]]);export{F as __pageData,_ as default};
