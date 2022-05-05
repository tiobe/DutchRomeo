package com.tiobe.julia;

import com.tiobe.antlr.JuliaParser;
import org.antlr.v4.runtime.BufferedTokenStream;

import java.util.List;

public class Rule1 extends Rule {
    public Rule1(final List<Violation> violations) {
        super(violations);
    }

    @Override
    public String getSynopsis() {
        return "TODO";
    }

    public void check(final JuliaParser.DeclarationContext ctx, final BufferedTokenStream tokens) {
        addViolation(1, ctx, "TODO");
    }
}
