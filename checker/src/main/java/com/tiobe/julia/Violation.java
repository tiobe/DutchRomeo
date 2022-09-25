package com.tiobe.julia;

import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.tree.TerminalNode;

public class Violation {
    Violation(final Rule rule, final ParserRuleContext ctx) {
        this(rule, ctx, "");
    }

    Violation(final Rule rule, final ParserRuleContext ctx, final String extraMessage) {
        this(rule, ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine(), extraMessage);
    }

    Violation(final Rule rule, final TerminalNode node, final String extraMessage) {
        this(rule, node.getSymbol().getLine(), node.getSymbol().getCharPositionInLine(), extraMessage);
    }

    Violation(final Rule rule, final int lineNumber, final int columnNumber) {
        this(rule, lineNumber, columnNumber, "");
    }

    Violation(final Rule rule, final int lineNumber, final int columnNumber, final String extraMessage) {
        this.rule = rule;
        this.lineNumber = lineNumber;
        this.columnNumber = columnNumber;
        this.extraMessage = extraMessage;
    }

    public void printToStdout(final String filename) {
        System.out.println();
        System.out.println(filename + "(" + lineNumber + ":" + columnNumber + "):");
        System.out.println("  Synopsis: " + rule.getSynopsis());
        System.out.println("  Rule ID: " + rule.getRuleId());
        if (!extraMessage.isEmpty()) {
            System.out.println("  " + extraMessage);
        }
    }

    public int getLineNumber() {
        return this.lineNumber;
    }

    private final Rule rule;
    private final int lineNumber;
    private final int columnNumber;
    private final String extraMessage;
}
