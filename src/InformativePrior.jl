module InformativePrior

using Franklin

"""
Adapted from Franklin code at src/manager/post_processing.jl:126

This is a simple wrapper doing a git commit and git push without much
fanciness. It assumes the current directory is a git folder.
It also fixes all links if you specify `prepath` (or if it's set in
`config.md`).

**Keyword arguments**

* `prerender=true`: prerender javascript before pushing see
                     [`optimize`](@ref)
* `minify=true`:    minify output before pushing see [`optimize`](@ref)
* `nopass=false`:   set this to true if you have already run `optimize`
                     manually.
* `prepath=""`:     set this to something like "project-name" if it's a
                     project page
* `message="franklin-update"`: add commit message.
* `cleanup=true`:   whether to cleanup environment dictionaries (should
                     stay true).
* `final=nothing`:  a function `()->nothing` to execute last, before doing
                     the git push. It can be used to refresh a Lunr index,
                     generate notebook files with Literate, etc, ...
                     You might want to compose `fdf_*` functions that are
                     exported by Franklin (or imitate those). It can
                     access GLOBAL_VARS.
"""
function deploy(; prerender::Bool=true, minify::Bool=true, nopass::Bool=false,
                   prepath::String="", message::String="franklin-update",
                   cleanup::Bool=true, final::Union{Nothing,Function}=nothing,
                   do_push::Bool=true)::Nothing
    succ = true
    if !isempty(prepath) || !nopass
        # no cleanup so that can access global page variables in final step
        succ = optimize(prerender=prerender, minify=minify,
                        sig=true, prepath=prepath, cleanup=false)
    end
    if succ
        # final hook
        final === nothing || final()
        # --------------------------
        run(`rm -rf __production`)
        run(`cp -r __site/\* __production`)

        # Push to git (publication)
        start = time()
        pubmsg = rpad("→ Pushing updates with git...", 35)
        print(pubmsg)
        try
            run(`git add -A `)
            wait(run(`git commit -m "$message" --quiet`; wait=false))
            if do_push
                run(`git push --quiet`)
            end
            print_final(pubmsg, start)
        catch e
            println("✘ Could not push updates, verify your connection " *
                    "and/or try manually.\n")
            @show e
        end
    else
        println("✘ Something went wrong in the optimisation step. " *
                "Not pushing updates.")
    end
    return nothing
end


end
