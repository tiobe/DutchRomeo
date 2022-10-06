package com.tiobe.julia;

import com.tiobe.antlr.JuliaParser;
import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.BufferedTokenStream;
import org.antlr.v4.runtime.misc.Pair;

import java.util.ArrayList;
import java.util.List;

public class Rule1 extends Rule {
    public Rule1(final List<Violation> violations) {
        super(violations);
    }

    @Override
    public String getSynopsis() {
        return "Cyclomatic Complexity";
    }

    public void check(final JuliaParser.MainContext ctx, final BufferedTokenStream tokens) {
        // code at global level
        if (ctx.functionBody() != null) {
            results.add(new Pair<>(ctx, getCyclox(ctx)));
            ctx.functionBody().forEach(this::check);
        }

        // code in functions
        ctx.functionDefinition().forEach(this::check);
        results.forEach(x -> addViolation(1, x.a,
                "Cyclomatic complexity of function '" + getFunctionName(x.a) + "' is " + (x.b + 1)));
    }

    private void check(final JuliaParser.FunctionDefinitionContext ctx) {
        final JuliaParser.FunctionBodyContext fbtx = getFunctionBody(ctx);
        results.add(new Pair<>(ctx, getCyclox(fbtx)));
        check(fbtx);
    }

    private void check(final JuliaParser.FunctionDefinition1Context ctx) {
        results.add(new Pair<>(ctx, getCyclox(ctx.functionBody())));
        check(ctx.functionBody());
    }

    private void check(final JuliaParser.FunctionBodyContext ctx) {
        ctx.statement().forEach(this::check);
    }

    private void check(final JuliaParser.StatementContext ctx) {
        if (ctx.forStatement() != null) {
            check(ctx.forStatement().functionBody());
        } else if (ctx.ifStatement() != null) {
            ctx.ifStatement().functionBody().forEach(this::check);
        } else if (ctx.functionDefinition1() != null) {
            check(ctx.functionDefinition1());
        } else if (ctx.tryCatchStatement() != null) {
            ctx.tryCatchStatement().functionBody().forEach(this::check);
        } else {
            check(ctx.whileStatement().functionBody());
        }
    }

    private String getFunctionName(final ParserRuleContext ctx) {
        if (ctx instanceof JuliaParser.FunctionDefinition1Context && ((JuliaParser.FunctionDefinition1Context) ctx).IDENTIFIER() != null) {
            return ((JuliaParser.FunctionDefinition1Context) ctx).IDENTIFIER().getText();
        } else if (ctx instanceof JuliaParser.FunctionDefinition2Context) {
            return ((JuliaParser.FunctionDefinition2Context) ctx).IDENTIFIER().getText();
        } else {
            return "<unnamed>";
        }
    }

    private JuliaParser.FunctionBodyContext getFunctionBody(final JuliaParser.FunctionDefinitionContext ctx) {
        return ctx.functionDefinition1() != null ? ctx.functionDefinition1().functionBody() : ctx.functionDefinition2().functionBody();
    }

    private int getCyclox(final JuliaParser.MainContext ctx) {
        return ctx.functionBody().stream().map(this::getCyclox).reduce(0, Integer::sum);
    }

    private int getCyclox(final JuliaParser.FunctionBodyContext ctx) {
        return ctx.statement().stream().map(this::getCyclox).reduce(0, Integer::sum);
    }

    private int getCyclox(final JuliaParser.StatementContext ctx) {
        if (ctx.forStatement() != null) {
            return 1 + getCyclox(ctx.forStatement().functionBody());
        } else if (ctx.ifStatement() != null) {
            return 1 + ctx.ifStatement().functionBody().stream().map(this::getCyclox).reduce(0, Integer::sum);
        } else if (ctx.functionDefinition1() != null) {
            return 0; // a nested function definition is encountered, which will be treated separately
        } else if (ctx.tryCatchStatement() != null) {
            return 1 + ctx.tryCatchStatement().functionBody().stream().map(this::getCyclox).reduce(0, Integer::sum);
        } else {
            return 1 + getCyclox(ctx.whileStatement().functionBody());
        }
    }

    private final List<Pair<ParserRuleContext, Integer>> results = new ArrayList<>();
}
