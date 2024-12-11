module LocalCustoms
    export @local_
    export @localimport, @localexport

    """

        @local_ import ModuleName
        @local_ import ModuleName: name
        @local_ import ModuleName: name1, name2, ...

    Import names belonging to a local module (i.e. already in the namespace).

    Do not include a `.` before the module name!

    When only a composite ModuleName is provided (e.g. `Gadgets.Things.Doohickies`),
        the innermost module (i.e. `Doohickies`) is imported into the active namespace.

    Otherwise, this macro is just a verbose way of avoiding the `.`. :)

        @local_ export ModuleName
        @local_ export ModuleName: name
        @local_ export ModuleName: name1, name2, ...

    Export names belonging to a local module (i.e. already in the namespace).

    Do not include a `.` before the module name!

    The point of this macro is to export names of a subordinate module
        without having to (explicitly) import them first.

    When a nested module is provided (e.g. `Gadgets.Things.Doohickies`),
        ...this macro doesn't work.
    Sorry. The Julia parser doesn't expect any operators after an export name.
    It's a total fluke that the `:` signatures parse as expressions at all.
    You can use the alternative macro `@localexport` for such cases.

    """
    macro local_(expr::Expr)
        return expr.head == :import ? _importfromlocal_(expr) : _exportfromlocal_(expr)
    end

    function _importfromlocal_(importexpr::Expr)
        @assert importexpr.head == :import

        if only(importexpr.args).head == :. # as opposed to :(:)
            modulenode = only(importexpr.args)
            if length(modulenode.args) > 1
                # `@local_ import Outer.Inner` => `import Outer: Inner`
                lastnode = Expr(:., pop!(modulenode.args))
                importexpr.args[1] = Expr(:(:), modulenode, lastnode)
            end
        else
            colonnode = only(importexpr.args)
            modulenode = first(colonnode.args)
        end
        pushfirst!(modulenode.args, :.) # PREPEND`.` FOR A MODULE ALREADY IN NAMESPACE
        return importexpr
    end

    function _exportfromlocal_(exportexpr::Expr)
        if exportexpr.head == :export
            # If the parser calls this an export, it's just a module, with no names.
            # By contract, the module is already in the namespace, so no need to import.
            return exportexpr
        end

        theweirdcall = exportexpr.head == :call ? exportexpr : first(exportexpr.args)
        modulename, firstname = _extractnamesfrom(theweirdcall)
        othernames = exportexpr.head == :call ? [] : exportexpr.args[2:end]
        return _localexport(modulename, firstname, othernames...)
    end

    """
        @localimport ModuleName
        @localimport ModuleName name1
        @localimport ModuleName name1 name2 ...

    Import names belonging to a local module (i.e. already in the namespace).

    Do not include a `.` before the module name!

    The only difference between this macro and `@local_ import` is the syntax.
    Both are provided for the sake of symmetry with exports.

    When only a composite ModuleName is provided (e.g. `Gadgets.Things.Doohickies`),
        the innermost module (i.e. `Doohickies`) is imported into the active namespace.

    """
    macro localimport(modulename, names...)
        return _localimport(modulename, names...)
    end

    function _localimport(modulename::Symbol)
        # By contract, the module is already in the namespace.
        # So...we don't actually do anything here. ;)
        return :($nothing)
    end

    function _localimport(moduleexpr::Expr)
        modulenode = _prepmoduleforimport(moduleexpr)
        lastnode = Expr(:., pop!(modulenode.args))
        return Expr(:import, Expr(:(:), modulenode, lastnode))
    end

    function _localimport(modulename, names...)
        modulenode = _prepmoduleforimport(modulename)
        namenodes = _prepnamesforimport(names)
        return Expr(:import, Expr(:(:), modulenode, namenodes...))
    end

    """
        @localexport ModuleName
        @localexport ModuleName name1
        @localexport ModuleName name1 name2 ...

    Export names belonging to a local module (i.e. already in the namespace).

    Do not include a `.` before the module name!

    The chief difference between this macro and `@local_ export` is that
        this macro supports a composite ModuleName like `Gadgets.Things.Doohickies`.

    When only a composite ModuleName is provided (e.g. `Gadgets.Things.Doohickies`),
        the innermost module (i.e. `Doohickies`) is exported from the active namespace.

    """
    macro localexport(modulename, names...)
        return _localexport(modulename, names...)
    end

    function _localexport(modulename::Symbol)
        # By contract, `modulename` is already in the namespace, so no need to import it.
        return :(export $modulename)
    end

    function _localexport(moduleexpr::Expr)
        importexpr = _localimport(moduleexpr)
        lastname = last(moduleexpr.args).value
        return quote
            $importexpr
            export $lastname
        end
    end

    function _localexport(modulename, names...)
        importexpr = _localimport(modulename, names...)
        return quote
            $importexpr
            export $(names...)
        end
    end

    #= HELPER FUNCTIONS =#

    #=
        Import expressions consist of nodes with a `.` head. Dunno why.
        This function takes a module name and turns it into such a node.
    =#
    function _prepmoduleforimport(modulename::Symbol)
        return Expr(:., :., modulename) # PREPEND`.` FOR A MODULE ALREADY IN NAMESPACE
    end

    #=
        Import expressions consist of nodes with a `.` head. Dunno why.
        I might have naively guessed that a dot chain like `Gadgets.Things.Doohickies`
            *is* an expression with a `.` head.
        Indeed, that's exactly what it looks like when parsed within an import expression.
        But by itself, it turns out dot chains are defined recursively,
            and in a rather ugly way. (Why a `QuoteNode`?!)

        This function converts from the ugly way
            into the sensible notation that `import` expects.
    =#
    function _prepmoduleforimport(moduleexpr::Expr)
        args = []
        while moduleexpr isa Expr
            first, second = moduleexpr.args
            pushfirst!(args, second.value)
            moduleexpr = first
        end
        pushfirst!(args, moduleexpr)    # `moduleexpr` IS THE FIRST SYMBOL, AT THIS POINT

        return Expr(:., :., args...)    # PREPEND`.` FOR A MODULE ALREADY IN NAMESPACE
    end

    #=
        Import expressions consist of nodes with a `.` head. Dunno why.
        This function converts a list of names into a list of such nodes.
    =#
    function _prepnamesforimport(names)
        return [Expr(:., name) for name in names]
    end

    #=
        Export expressions were not designed to take operators after the name.
        Fortunately for us, the `:` operator is a higher precedence than `export`,
            so Julia does parse `export ModuleName: name` as an expression.

        But it does so in...a really strange way.
        It seems that `,` has the *highest* precedence, which I find *very* odd.

        Anyway, this function extracts the needed information from the `:` expression.
    =#
    function _extractnamesfrom(theweirdcall)
        modulename = only(theweirdcall.args[2].args)
        firstname = theweirdcall.args[3]
        return modulename, firstname
    end

end # module LocalCustoms
