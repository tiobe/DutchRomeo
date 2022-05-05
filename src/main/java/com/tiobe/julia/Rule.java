package com.tiobe.julia;

import com.tiobe.antlr.JuliaParser;
import org.antlr.v4.runtime.BufferedTokenStream;
import org.antlr.v4.runtime.ParserRuleContext;

import java.util.List;

public abstract class Rule {
    private final List<Violation> violations;

    public Rule(final List<Violation> violations) {
        this.violations = violations;
    }

    public String getRuleId() {
        return this.getClass().getSimpleName();
    }

    public abstract String getSynopsis();

    protected void addViolation(final int ruleID, final ParserRuleContext ctx, final String extraMessage) {
        addViolation(new Violation(this, ctx, extraMessage));
    }
    protected void addViolation(final Violation violation) {
        violations.add(violation);
    }

    public void check(final BufferedTokenStream tokens) {
    }

    public void check(final JuliaParser.MainContext ctx, final BufferedTokenStream tokens) {
    }

    public void check(final JuliaParser.FunctionDefinition1Context ctx, final BufferedTokenStream tokens) {
    }
}
