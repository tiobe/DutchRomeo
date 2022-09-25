package com.tiobe.julia;

import org.antlr.v4.runtime.BufferedTokenStream;

import java.util.List;
import com.tiobe.antlr.JuliaParser;

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
            addViolation(1, ctx,
                    "Cyclomatic complexity of function '<unnamed>' is " +
                            ctx.functionBody().stream().map(this::getCyclox).reduce(1, Integer::sum));
        }

        // code in functions
        ctx.functionDefinition().forEach(fdctx -> addViolation(1, fdctx,
                "Cyclomatic complexity of function '" + getFunctionName(fdctx) + "' is " + (getCyclox(fdctx) + 1)));
    }

    private String getFunctionName(final JuliaParser.FunctionDefinitionContext ctx) {
        return ctx.functionDefinition1() != null ?
                ctx.functionDefinition1().IDENTIFIER().getText() : ctx.functionDefinition2().IDENTIFIER().getText();
    }

    private int getCyclox(final JuliaParser.FunctionDefinitionContext ctx) {
        return ctx.functionDefinition1() != null ?
                getCyclox(ctx.functionDefinition1().functionBody()) : getCyclox(ctx.functionDefinition2().functionBody());
    }

    private int getCyclox(final JuliaParser.FunctionBodyContext ctx) {
        return ctx.statement().stream().map(this::getCyclox).reduce(0, Integer::sum);
    }

    private int getCyclox(final JuliaParser.StatementContext ctx) {
        if (ctx.forStatement() != null) {
            return 1 + getCyclox(ctx.forStatement().functionBody());
        } else if (ctx.ifStatement() != null) {
            return 1 + ctx.ifStatement().functionBody().stream().map(this::getCyclox).reduce(0, Integer::sum);
        } else if (ctx.tryCatchStatement() != null) {
            return 1 + ctx.tryCatchStatement().functionBody().stream().map(this::getCyclox).reduce(0, Integer::sum);
        } else {
            return 1 + getCyclox(ctx.whileStatement().functionBody());
        }
    }
}
